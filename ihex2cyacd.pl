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

$line = 0;
$total_bc = 0;
# verbose
$v = 0;

$cyacd_line = "";
$odd = 1;
$odd_z = 0;
$start_cyacd = 0;
$print_cyacd = 0;
$short = 0;
$bootloader_text_size = $ARGV[0] ;
$flash_row_size = $ARGV[1];
$in_file = $ARGV[2];
$out_file = $ARGV[3];
shift;
shift;
shift;
shift;
$silicon_id="04161193";
$silicon_rev="11";
$checksum_type="00";
$boot_loader_text_rows = int($bootloader_text_size/$flash_row_size);
$lines_to_skip = $boot_loader_text_rows * 2;
$cyacd_i = $boot_loader_text_rows;
# print "cyacd_i = ". $cyacd_i . "\n";
# print "Rows = " . $boot_loader_text_rows . "\n";  
# print "Line to skip " . $lines_to_skip . "\n";
open ($IFH, "<", $in_file ) || die "Unable to read hex file " . $in_file . "\n";
open ($OFH, ">", $out_file ) || die "Unable to create cyacd file " . $out_file . "\n";
# print "041611931100\n";
print $OFH $silicon_id . $silicon_rev . $checksum_type . "\n";

while(<$IFH>) {
    print "Line : $line ::: $_" if ( $v == 1 );
    if (/:(..)(....)(..)(.*)(...)/) {
	# print "Byte Count : $1\n" if ( $v == 1 );
	$bc = $1;
	next if ( $bc != 40);
	# print "Bytecount = $bc\n";
	# $total_bc = $total_bc + $bc;
	# print "Address    : $2\n" if ( $v == 1 );
	# $addr = $2;
	# print "Record Type: $3 : " if ( $v == 1 );
	# $rt = $3;
	# if ( $rt == "00" ) {
	#    print " Data" if ( $v == 1 );
	# }
	# if ( $rt == "01" ) {
	#    print "EOF" if ( $v == 1 );
	# }
	# if ( $rt == "02" ) {
	#    print "Extended Segment Address" if ( $v == 1 );
	# }
	# if ( $rt == "03" ) {
	#    print "Start Segment Address" if ( $v == 1 );
	# }
	# if ( $rt == "04" ) {
	#    print "Extended Linear Address" if ( $v == 1 );
	# }
	# if ( $rt == "05" ) {
	#    print "Start Linear Address" if ( $v == 1 );
	# }
	# print "\n" if ( $v == 1 );
	# print "Data       : $4\n" if ( $v == 1 );
	$data_all = $4;
	# @data = unpack("(A[2])*",$4);
	# for ($i=0; $i<($#data + 1); $i++) {
	#    print $i . " " . @data[$i] . "\n" if ( $v == 1 );
	# }
	# $cs  = $5;
	# print "Checksum   : $5\n\n\n" if ( $v == 1 );
	if ( $line < $lines_to_skip ) {
	    $start_cyacd = 0;
	    $print_cyacd = 0;
	} else {
	    $start_cyacd = 1;
	    $print_cyacd = 1;
	}
	if ( $odd == 1 ) {
	    $cyacd_line = "";
	    $print_cyacd = 1;
	    if ($data_all =~ /\A['0']+\Z/ ) {
		$odd_z = 1;
	    } else {
		$odd_z = 0;
	    }
	    $cyacd_line = ":00" . sprintf("%04X",$cyacd_i) . "0080" ;
	    $cyacd_line .= $data_all;
	    $odd = 0;
	} else {
	    if ($data_all =~ /\A['0']+\Z/ ) {
		if ($odd_z == 1) {
		    $print_cyacd = 0;
		}
	    }
	    if ( $print_cyacd == 1) {
		$cyacd_line .= $data_all;
		$binval = pack( 'H*', substr($cyacd_line,1));
		$checksum = unpack( "%8C*", $binval );
		# $checksum = (0xff-$checksum+1) & 0xff;
		$checksum = (0xff-$checksum+1) & 0x00ff;
		print $OFH $cyacd_line . sprintf("%02X",$checksum). "\n";	
	    }
	    if ( $start_cyacd == 1 ) {
		$cyacd_i += 1;
	    }
	    $odd = 1;
	}	
    } else {
	print "Error" if ( $v == 1 );
    }
    $line++;
}
# print "\nTotal bytes = " . $total_bc . "\n";
close($IFH);
close($OFH);
