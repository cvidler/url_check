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

# parse regexinput file.
cat $REGEXFILE | while read -r regex; do

	echo "Testing URL Definition: $regex"
	echo "Testing URL Definition: $regex" >> $OUTFILE

#extra debug, shows all command lines run
set -x

	echo "Raw Matches: Count, Line#, RawURL" >> $OUTFILE
	# perl-ify regex
	# DC RUM regex syntax is not-strictly enforced, perl requires strict syntax, so we'll fix what we can (typically we have to escape '/' forward-slash characters).
	perlregex=${regex//\//\\/}
	echo $perlregex
	#cat $INFILE | gawk -v regexvar="$regex" ' $0 ~ regexvar { i++; printf("%i,%i,%s\n", i,NR,$1) } ' >> $OUTFILE
	cat $INFILE | perl -ne'++$l && /'$perlregex'/ && ++$i && print "$i,$l,$&\n" ' >> $OUTFILE
	echo "AMD Output: Count, ReportedURL" >> $OUTFILE
	#cat $INFILE | gawk -v regexvar="$regex" ' $0 ~ regexvar { res = gensub(regexvar, "boo \\1:\\2:\\3:\\4:", "g", $0); !a[res]++; i++; printf("%i,%s\n", i, res ); } ' >> $OUTFILE
	cat $INFILE | perl -ne's/'$perlregex'/\1\2\3\4\5\6\7\8\9/ && ++$i && print "$i,$1$2$3$4$5$6$7$8$9\n"' >> $OUTFILE


	echo "" >> $OUTFILE

done 
