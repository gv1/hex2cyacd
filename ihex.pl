# sample:
# Line : 518 ::: :0200000490600A
# Recordstart: :
# Byte Count : 02
# Address    : 0000
# Record Type: 04
# Data       : 9060
# Checksum   : 0A
# 
# checksum: 0x0A = 0x100 ­ (0x02+0x00+0x00+0x04+0x90+0x60)

 
$line = 0;
$let = '[0-9a-fA-F]';
$total_bc = 0;
$v = 0;
while(<>) {
print "Line : $line ::: $_" if ( $v == 1 );
$line++;
if (/:($let.)(....)(..)(.*)(...)/) {
	print "Byte Count : $1\n" if ( $v == 1 );
	$bc = $1;
	$total_bc = $total_bc + $bc;
	print "Address    : $2\n" if ( $v == 1 );
	$addr = $2;
	print "Record Type: $3 : " if ( $v == 1 );
	$rt = $3;
	if ( $rt == "00" ) {
		print " Data" if ( $v == 1 );
	}
	if ( $rt == "01" ) {
		print "EOF" if ( $v == 1 );
	}
	if ( $rt == "02" ) {
		print "Extended Segment Address" if ( $v == 1 );
	}
	if ( $rt == "03" ) {
		print "Start Segment Address" if ( $v == 1 );
	}
	if ( $rt == "04" ) {
		print "Extended Linear Address" if ( $v == 1 );
	}
	if ( $rt == "05" ) {
		print "Start Linear Address" if ( $v == 1 );
	}
	print "\n" if ( $v == 1 );
	print "Data       : $4\n" if ( $v == 1 );
	# @data = ('aa','ab','ac');
	# split to groups of two:
	@data = unpack("(A[2])*",$4);
	for ($i=0; $i<($#data + 1); $i++) {
		print $i . " " . @data[$i] . "\n" if ( $v == 1 );
	}
	print "Checksum   : $5\n\n\n" if ( $v == 1 );
	$cs  = $5;
} else {
  print "Error" if ( $v == 1 );
}
}
print "\nTotal bytes = " . $total_bc . "\n";
