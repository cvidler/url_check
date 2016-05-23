# parse_definition.sh
# Chris Vidler - Dynatrace DC RUM SME - 2016
#
# Takes the XML from 'edit as text' in RUM Console extacting URL definitions (regex/static) to the use as test data
#

# get/parse command line options
ISET=0
OSET=0
OPTS=0
DEBUG=0
while getopts ":dhi:o:" OPT; do
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

if [ $ISET -eq 0 ] || [ $OSET -eq 0 ]; then OPTS=0; fi

if [ $OPTS -eq 0 ]; then
	echo -e "*** INFO: Usage: $0 [-h] -i inputfile -o outputfile"
	echo -e "-h This help"
	echo -e "-i inputfile XML output from RUM Console 'edit as text'. Required"
	echo -e "-o outputfile Output used by URL parsing script as input. Required"
	exit 0
fi

# parse input file.
# we're looking for <regexId> tag (regex), or ? (static url)

# clear outfile
echo -n "" > $OUTFILE
# parse the regexs
cat $INFILE | awk ' /<regexId>.*<\/regexId>/ { gsub(/<\/?regexId>/,""); print $1 } ' >> $OUTFILE



