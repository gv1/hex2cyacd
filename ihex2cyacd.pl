#
# sample:

# .cyacd file format
#  [4-byte SiliconID][1-byte SiliconRev][checksum type]
#  The data records have the format:
#  [1-byte ArrayID][2-byte RowNumber][2-byte DataLength][N-byte Data][1byte Checksum]
#  The Checksum is computed by summing all bytes (excluding the checksum itself) and then taking the 2's complement.
# eg:
# Line 518 ":0200000490600A"
# Recordstart: ":"
# Byte Count : 0x02
# Address    : 0x0000
# Record Type: 0x04
# Data       : "9060" : 0x90 0x60
# Checksum   : 0x0A
# 
# checksum: 0x0A = 0x100 ­ (0x02+0x00+0x00+0x04+0x90+0x60)
#

# Procedure:
# use arm-none-eabi-size to determine text size.
# eg
# arm-none-eabi-size --format=Berkeley Bootloadable\ Blinking\ LED.elf
#   text    data     bss     dec     hex filename
#   6464      24    1512    8000    1f40 Bootloadable Blinking LED.elf
# Number of rows 
# arm-none-eabi-size --format=Berkeley UART_Bootloader.elf 
#   text    data     bss     dec     hex filename
#   4456      32    1672    6160    1810 UART_Bootloader.elf
# Conversion
#   Bootloader size  = 4456/128 = 34 = 0x22. So skip 0-0x22*2 lines 
#    lines in 
# start .cyacd with row number 0x0022. Skip lines 0- (0x22*2)-1 , since hex file has 64 byte size lines.
# so, skip 34*2 lines in .hex file. Combine the next two lines each from hex 
# file to form a single line of text in .cyacd file. Calculate new checksum 
# and append. Repeat till end, and again skip lines that are not 64 bytes.Also skip lines with "\A['0']+\Z" data - all zeros.
# current version is extended to check the byte count from hex file, and do the
# conversion accordingly.

$line = 0;
$total_bc = 0;
# verbose
$v = 0;

$cyacd_line = "";
$start_of_cyacd_line = 1;
$end_of_cyacd_line = 0;
$zeros_data = 0;
$start_cyacd = 0;
$print_cyacd = 0;
$short = 0;
$skip_line = 0;
$lines_to_combine = 0;
$lines_to_combine_cnt = 0;
( $bootloader_text_size, $flash_row_size, $in_file, $out_file ) = @ARGV;
$silicon_id="04161193";
$silicon_rev="11";
$checksum_type="00";
open ($IFH, "<", $in_file ) || die "Unable to read hex file " . $in_file . "\n";
open ($OFH, ">", $out_file ) || die "Unable to create cyacd file " . $out_file . "\n";
print $OFH $silicon_id . $silicon_rev . $checksum_type . "\n";

while(<$IFH>) {
    print "Line : $line ::: $_" if ( $v == 1 );
    if (/:(..)(....)(..)(.*)(...)/) {
	$bc = hex($1);
	if ( $line == 0 ) {
	    $input_bc = $bc;
	    # number of text rows in bootloader elf
	    $boot_loader_text_rows = int($bootloader_text_size/$flash_row_size);
	    # start row count in .cyacd
	    $cyacd_row_cnt = $boot_loader_text_rows; 
	    # number of lines from input hex to form the required data line 
	    $lines_to_combine = $flash_row_size/$bc;	    
	    # number of lines corresponding to bootloader
	    $lines_to_skip = $boot_loader_text_rows * $lines_to_combine;
	    print "cyacd_row_cnt = ". $cyacd_row_cnt . "\n" if ( $v == 1);
	    print "Rows = " . $boot_loader_text_rows . "\n" if ( $v == 1);
	    print "Lines to combine " . "$flash_row_size / $bc = " . $lines_to_combine . "\n" if ($v == 1);
	    print "Line to skip " . $lines_to_skip . "\n" if ( $v == 1);
	}
	next if ( $bc != $input_bc);
	$input_line_data = $4;
	if ( $line < $lines_to_skip ) {
	    $skip_line = 1;
	    $start_cyacd = 0;
	    $print_cyacd = 0;
	    $cyacd_line = "";
	    $line++;
	} else {
	    $skip_line = 0;
	    $start_cyacd = 1;
	    $print_cyacd = 1;
	}
	next if ( $skip_line == 1);
	if ( $start_of_cyacd_line == 1 ) {
	    $cyacd_line = "";
	    $print_cyacd = 1;
	    if ($input_line_data =~ /\A['0']+\Z/ ) {
		$zeros_data = 1;
	    } else {
		$zeros_data = 0;
	    }
	    $cyacd_line = ":00" . sprintf("%04X",$cyacd_row_cnt) . "0080" ;
	    $cyacd_line .= $input_line_data;
	    $end_of_cyacd_line = 0;
	    $lines_to_combine_cnt = 0;
	    $start_of_cyacd_line = 0;
	} else {
	    $cyacd_line .= $input_line_data;
	    if ($lines_to_combine_cnt == ($lines_to_combine - 2)) {
		$end_of_cyacd_line = 1;
		$print_cyacd = 1;
		$lines_to_combine_cnt = 0;
	    } else {
		$lines_to_combine_cnt++;
	    }
	    if ( $end_of_cyacd_line == 0 ) {
		if ($input_line_data =~ /\A['0']+\Z/ ) {
		    if ($zeros_data == 1) {
			$print_cyacd = 0;
		    }
		} else {
		    $zeros_data = 0;
		    $print_cyacd = 1;
		}
	    } else {		
		if ($input_line_data =~ /\A['0']+\Z/ ) {
		    if ($zeros_data == 1) {
			$print_cyacd = 0;
			$zeros_data = 0;
			$start_of_cyacd_line = 1;				    
			$lines_to_combine_cnt = 0;
		    }
		} else {
		    $zeros_data = 0;
		}
		if ( $print_cyacd == 1) {
		    $binval = pack( 'H*', substr($cyacd_line,1));
		    $checksum = unpack( "%8C*", $binval );
		    $checksum = (0xff-$checksum+1) & 0x00ff;
		    print $OFH $cyacd_line . sprintf("%02X",$checksum). "\n";	
		    $print_cyacd = 0;
		    $zeros_data = 0;
		    $start_of_cyacd_line = 1;				    
		    $lines_to_combine_cnt = 0;
		}
		if ( $start_cyacd == 1 ) {
		    $cyacd_row_cnt += 1;
		}
	    }
	}	
    } else {
	print "Error" if ( $v == 1 );
    }
    $line++;
}
close($IFH);
close($OFH);
