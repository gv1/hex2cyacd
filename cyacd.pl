# sample:
#  The header record has the format:
#  [4-byte SiliconID][1-byte SiliconRev]
#  The data records have the format:
#  [1-byte ArrayID][2-byte RowNumber][2-byte DataLength][N-byte Data][1byte Checksum]
#  The Checksum is computed by summing all bytes (excluding the checksum itself) and then taking the 2's complement.
# eg:
# 041611931100
# :00002100800010002091100000A1120000A112000080B500AF024B83F3088800F005F9C0460010002080B500AF104B104A12688021C9020A431A60032000F072FA0B4B0B4A11680B4A0A401A600A4B0B4A1A600B4B10221A600A4B802212061A60094B0A4A1A600A4B00221A60BD4680BD00010B40FFFFFBFF04010B4006000080200202404B
# cybtldr_command.h, 22
# STANDARD PACKET FORMAT:
# Multi byte entries are encoded in LittleEndian.
# /*******************************************************************************
# * [1-byte] [1-byte ] [2-byte] [n-byte] [ 2-byte ] [1-byte]
# * [ SOP  ] [Command] [ Size ] [ Data ] [Checksum] [ EOP  ]
# *******************************************************************************/

 
$line = 0;
$let = '[0-9a-fA-F]';
$total_bc = 0;
$v = 1;
while(<>) {
    if ( $line == 0 ) {
	if (/(........)(..)(..)/) {
		$silicon_id = $1;
		$rev = $2;
		$checksum_type = $3;
		print "Silicon ID : 0x". $1 . " Rev " . hex($2). "\n"; 	    
	} else {
	    
	}         
	$line++;
    } else {
	print "Line : $line ::: $_" if ( $v > 0 );
	$line++;
	if (/:(..)(....)(....)(.*)(...)/) {
	    $array_id = $1;
	    print "array_id : $1\n" if ( $v > 0 );
	    $row_number = $2;
	    print "row_number   : $2\n" if ( $v > 0 );
	    $data_length = $3;
	    print "data_length: 0x$3 = " . hex($3) . "\n" if ( $v > 0 );
	    $total_bc = $total_bc + $data_length;
	    print "Data       : $4\n" if ( $v > 0 );
	    # @data = ('aa','ab','ac');
	    # split to groups of two:
	    @data = unpack("(A[2])*",$4);
	    # $#data + 1 == scalar(@data) == 128 for 0x0080
	    print "length = " . ($#data + 1) . "\n";
	    $csc = 0;
	    for ($i=0; $i<($#data + 1); $i++) {
		print $i . " " . @data[$i] . "\n" if ( $v > 1 );
		# $csc = ($csc + hex($data[$i]))&0x0000000000ff;
	    }
	    # $csc = (~$csc + 1)&0x0000000ff ;
	    # printf "Calculated checksum = 0x%x"  . $csc . "\n";
	    $cs  = $5;
	    print "Checksum   : $5\n\n\n" if ( $v > 0 );
	} else {
	    print "Error" if ( $v > 0 );
	}
    }
}
print "\nTotal bytes = " . $total_bc . "\n";
