# parse_urls.sh
# Chris Vidler - Dynatrace DC RUM SME - 2016
#
# Take a list of URLs and the RUM Console URL definition rules, and report on which regexs match which URLs
#

# get/parse command line options
ISET=0
RSET=0
OSET=0
OPTS=0
DEBUG=0
while getopts ":dhi:r:o:" OPT; do
	case $OPT in
		h)
			OPTS=0  #show help
			;;
		d)
			DEBUG=$((DEBUG + 1))
			;;
		i)
			if [ $ISET -ne 0 ] ; then OPTS=0; fi
			INFILE=$OPTARG
			ISET=1
			OPTS=1
			;;
		r)
			if [ $RSET -ne 0 ] ; then OPTS=0; fi
			REGEXFILE=$OPTARG
			RSET=1
			OPTS=1
			;;
		o)
			if [ $OSET -ne 0 ]; then OPTS=0; fi
			OUTFILE=$OPTARG
			OSET=1
			OPTS=1
			;;
		\?)
			OPTS=0 #show help
			echo "*** FATAL: Invalid argument -$OPTARG."
			;;
		:)
			OPTS=0 #show help
			echo "*** FATAL: argument -$OPTARG requires parameter."
			;;
	esac
done

if [ $ISET -eq 0 ] || [ $RSET -eq 0 ] || [ $OSET -eq 0 ]; then OPTS=0; fi

if [ $OPTS -eq 0 ]; then
	echo -e "*** INFO: Usage: $0 [-h] -r regexfile -i urlinputfile -o outputfile"
	echo -e "-h This help"
	echo -e "-r regexinputfile Output from parse_definitions.sh script. Required"
	echo -e "-i urlinputfile List of URLs to test, one per line. Required"
	echo -e "-o outputfile Output file. Required"
	exit 0
fi

# clear output file
echo -n "" > $OUTFILE

tmpfile=`mktemp`
tmpfile2=`mktemp`
#echo $tmpfile
# prep tmpfile
cp $INFILE $tmpfile

# parse regexinput file.
cat $REGEXFILE | while read -r regex; do

	echo "Testing URL Definition: $regex"
	echo "Testing URL Definition: $regex" >> $OUTFILE

#extra debug, shows all command lines run
#set -x

	echo "Raw Matches: Count, Line#, RawURL" >> $OUTFILE
	# perl-ify regex
	# DC RUM regex syntax is not-strictly enforced, perl requires strict syntax, so we'll fix what we can (typically we have to escape '/' forward-slash characters), and add a full string match so we can report them properly.
	perlregex=^${regex//\//\\/}.*$
	#echo $perlregex
	perl -ne'++$l && /'$perlregex'/ && ++$i && print "$i,$l,$&\n" ' $INFILE >> $OUTFILE
	echo "AMD Output: Count, Hits, ReportedURL" >> $OUTFILE
	perl -ne's/'$perlregex'/\1\2\3\4\5\6\7\8\9/ && print "$1$2$3$4$5$6$7$8$9\n"' $INFILE | perl -ne'{chop; $u{$_}++} END { print ++$i.",".$u{$_}.",".$_."\n" for keys %u} ' >> $OUTFILE

#set -x
	# find non-matching lines, process URL list in order (as per URL definitions) remaining URLs move to next regex, remaining ones after all regexs parsed are reported.
	#wc -l $tmpfile
	perl -ne'if ($_ !~/'$perlregex'/) { print $_ } ' $tmpfile > $tmpfile2
	mv $tmpfile2 $tmpfile
	#wc -l $tmpfile
#set +x

	#echo ""
	echo "" >> $OUTFILE

done 

echo "Non-Matching Lines: Count, RawURL" >> $OUTFILE
perl -ne'!/^[#\s]/ &&  print ++$i.",".$_ ' $tmpfile >> $OUTFILE
rm -f $tmpfile
rm -f $tmpfile2

echo "" >> $OUTFILE
echo "End" >> $OUTFILE
echo "Finished."
echo ""

