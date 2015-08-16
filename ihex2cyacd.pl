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

$alldata ="";
( $bootloader_text_size, $flash_row_size, $in_file, $out_file ) = @ARGV;
$boot_loader_text_rows = int($bootloader_text_size/$flash_row_size);
$cyacd_row_cnt = $boot_loader_text_rows; 
# start row count in .cyacd
$cyacd_row_cnt = $boot_loader_text_rows; 
$total_bytes_to_skip=$bootloader_text_size;
$silicon_id="04161193";
$silicon_rev="11";
$checksum_type="00";
open ($IFH, "<", $in_file ) || die "Unable to read hex file " . $in_file . "\n";
open ($OFH, ">", $out_file ) || die "Unable to create cyacd file " . $out_file . "\n";
# add CR LF, as required by programmer sw tool, cybootload_linux, 0x0d 0x0a
# otherwise, following error occurs from programmer sw tool, cybootload_linux.
# [ERROR] The amount of data available is outside the expected range [0x3]
binmode($OFH,":crlf");
print $OFH $silicon_id . $silicon_rev . $checksum_type . "\n";
while(<$IFH>) {
    s/[\r\n]//g;
    $hexrec = $_;
    ( $length, $addr, $type, $data_cs ) = unpack( 'A2 A4 A2 A*', substr($hexrec,
1) );
    $len=hex($length)*2;
    ($data, $cs) = unpack("A$len A2",$data_cs);
    $alldata .= $data;
    $binrec = pack( 'H*', substr( $hexrec, 1 ) );
    die "bad checksum : $hexrec" unless unpack( "%8C*", $binrec ) == 0;
}
close($IFH);
$len=$flash_row_size*2;
@o = unpack( "(A$len)*",$alldata);
$skip = $total_bytes_to_skip ; // * $flash_row_size;
$line = 0;
for $data (@o) {
    $line++;
    next if ( $line * $flash_row_size < $skip );
    next if ( $data =~ /\A['0']*\Z/ );
    next if ( length($data) < 128 * 2);
    $cyacd_data = ":00". sprintf("%04X",$line-1) . sprintf("%04X",length($data)/2) . $data ;
    $binrec = pack( 'H*', substr( $cyacd_data, 1 ) );
    $cs = unpack( "%8C*", $binrec );
    $cs = (0xff-$cs+1) & 0x00ff;
    $cyacd_data .= sprintf("%02X",$cs) ;
    $binrec = pack( 'H*', substr( $cyacd_data , 1 ) );
    die "bad checksum : $hexrec" unless unpack( "%8C*", $binrec ) == 0;
    print $OFH  $cyacd_data . "\n"; # unpack("A*",$data) . "\n"; 
}
close($OFH);
