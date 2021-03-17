#!/usr/bin/env bash
set -euo pipefail

ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-l] [-g] [-v] [-d]

Small data and email validation toolkit.

Available options:
	
-h		Print this help and exit
-l		Account breach search by domain name (using blackkitetech.com)
-g		Email Harvester wrapper (EmailHarvester.py needed)
-v		Email verification, API KEY NEEDED (using quickemailverification.com)
-d		Download EmailHarvester.py and requirements file. 
		Then just run pip install -r requirements.txt
EOF
  exit
}


while getopts l:g:v:hd flag
do
case "${flag}" in
	l)	curl --silent -H "Content-Type: application/json" -X POST -d '{"domain": "'"$OPTARG"'"}' https://services.blackkitetech.com/api/v1/breach/domain > $ABSDIR/.temp_leak.json
		jq -r '.results.breachList[].Email' $ABSDIR/.temp_leak.json;;

	g)	python3 $ABSDIR/EmailHarvester.py -e googles -d $OPTARG  > $ABSDIR/.temp_harvester 2> /dev/null
		grep '@' $ABSDIR/.temp_harvester;;

	v)	curl --get --silent "http://api.quickemailverification.com/v1/verify?email="${OPTARG}"&apikey=API KEY NEEDED!!!" > $ABSDIR/.temp_verify.json
		jq -r '.result, .reason' $ABSDIR/.temp_verify.json ;;

	h) usage;;

	d)	[[ -d $ABSDIR/plugins ]] && echo "[!]Plugins directory exist!" || mkdir $ABSDIR/plugins
		[[ -f $ABSDIR/plugins/googles.py ]] && echo "[!]/plugins/googles.py exist!" || curl --silent https://raw.githubusercontent.com/maldevel/EmailHarvester/master/plugins/googles.py -o $ABSDIR/plugins/googles.py
		[[ -f $ABSDIR/EmailHarvester.py ]] && echo "[!]EmailHarverster.py exist!" || curl --silent https://raw.githubusercontent.com/maldevel/EmailHarvester/master/EmailHarvester.py -o $ABSDIR/EmailHarvester.py 
		[[ -f $ABSDIR/requirements.txt ]] && echo "[!]Requirements.txt file exist!" || curl --silent https://raw.githubusercontent.com/maldevel/EmailHarvester/master/requirements.txt -o $ABSDIR/requirements.txt ;;

esac
done




