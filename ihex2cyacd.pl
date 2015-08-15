##############################################################################
#
#
#
#
#
# generate hex with: 
# arm-none-eabi-objcopy --gap-fill 0x00 -O ihex -v CY8CKIT-049-41XX_GPIO_Example.org.elf CY8CKIT-049-41XX_GPIO_Example.he
# Usage:
# 
# Eg makefile
# hex:
#        arm-none-eabi-objcopy --gap-fill 0x00 -O ihex -v CY8CKIT-049-41XX_GPIO_Example.org.elf CY8CKIT-049-41XX_GPIO_Example.hex

# BOOTLOADER=./UART_Bootloader.elf
# TSIZE=$(shell arm-none-eabi-size $(BOOTLOADER) | grep $(notdir $(BOOTLOADER)) | awk '{ print $$1 }')
# cyacd:
#        -rm -f CY8CKIT-049-41XX_GPIO_Example_new.cyacd
#        perl ../../hex2cyacd/ihex2cyacd.pl $(TSIZE) 128 CY8CKIT-049-41XX_GPIO_Example.hex CY8CKIT-049-41XX_GPIO_E
# xample_new.cyacd
#        diff CY8CKIT-049-41XX_GPIO_Example_new.cyacd CY8CKIT-049-41XX_GPIO_Example.org.cyacd
#
#flash:
#        ../../cybootload_linux/cybootload_linux CY8CKIT-049-41XX_GPIO_Example_new.cyacd


$line = 0;
$cyacd_line = "";
$start_of_cyacd_line = 1;
$end_of_cyacd_line = 
$line = 0;
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
$total_bc = 0;
( $bootloader_text_size, $flash_row_size, $in_file, $out_file ) = @ARGV;
$boot_loader_text_rows = int($bootloader_text_size/$flash_row_size);
$cyacd_row_cnt = $boot_loader_text_rows; 
# start row count in .cyacd
$cyacd_row_cnt = $boot_loader_text_rows; 
$total_bytes_to_skip=$bootloader_text_size;
$silicon_id="04161193";
$silicon_rev="11";
$checksum_type="00";
$remaining="";

open ($IFH, "<", $in_file ) || die "Unable to read hex file " . $in_file . "\n";
open ($OFH, ">", $out_file ) || die "Unable to create cyacd file " . $out_file . "\n";
# add CR LF, as required by programmer sw tool, cybootload_linux, 0x0d 0x0a
# otherwise, following error occurs from programmer sw tool, cybootload_linux.
# [ERROR] The amount of data available is outside the expected range [0x3]
binmode($OFH,":crlf");
print $OFH $silicon_id . $silicon_rev . $checksum_type . "\n";
$cyacd_record = "";
$cyacd_record_start = 1; # start of record
$cyacd_record_bc = 0; # bytes in this record
while(<$IFH>) {
    $line++;
    chop;
    chop;
    $hexrec=$_;
    ( $length, $addr, $type, $data_cs ) = unpack( 'A2 A4 A2 A*', substr($hexrec,1) );
    $len=hex($length)*2;
    ($data, $cs) = unpack("A$len A2",$data_cs);
    $bc = hex($length);	
    $total_bc += $bc;
    next if ( $total_bc < $total_bytes_to_skip);
    if ( $cyacd_record_start == 1 ) {
	$cyacd_record_header = ":00" . sprintf("%04X",$cyacd_row_cnt) . "0080" ;
	if ( $remaining ne "") {
	    $cyacd_record = $remaining . $data;
	    $cyacd_record_bc = length($remaining)/2 + $bc;
	} else {
	    $cyacd_record = $data;
	    $cyacd_record_bc = $bc;
	}
	$cyacd_record_start = 0;
	$cyacd_row_cnt += 1;
    } else {
	$cyacd_record .= $data;
	$cyacd_record_bc += $bc;
    }
    if ($cyacd_record_bc >= ($flash_row_size )) {
	if ( $cyacd_record_bc > ($flash_row_size )) {
	    ($cyacd_line,$remaining) = unpack("A267 A*",$cyacd_record_header . $cyacd_record );
	} else {
	    $cyacd_line = $cyacd_record_header . $cyacd_record ;
	}
	# skip if all zeros
	if ( $cyacd_record =~ /\A['0']+\Z/ ) {
	    # print $OFH "All zeros!\n";
	} else {
	    $binval = pack( 'H*', substr($cyacd_line,1));
	    $checksum = unpack( "%8C*", $binval );
	    $checksum = (0xff-$checksum+1) & 0x00ff;
	    print $OFH $cyacd_line . sprintf("%02X",$checksum). "\n";
	}
	$cyacd_record_start = 1;
    }
}
# if ( $cyacd_record_bc > 0 ) {
# print "Exit with $cyacd_record_header . $cyacd_record : $cyacd_record_bc\n";
#    $len = length( $cyacd_record )/2;
#    $cyacd_record .= '0' x (( 128 - $len )*2);
#    print $OFH $cyacd_record_header. $cyacd_record. "\n";
# }
close($IFH);
close($OFH);
