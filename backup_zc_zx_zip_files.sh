#!/bin/bash
#Backup .zip~ and .zip files from ORING to DEST and create a symbolic link in the original folder

#This script was written for a custom client, the options -zx and -zc were from the original project
#you can use -o and -d options for generic use 

#Basename
SELF=`basename $0`

#PATHS FOR PROJECT 1
ZC_LOCAL_ORIG='/var/PROJECT1/folder'
ZC_LOCAL_DEST='/backup/PROJECT1/folder'

#PATHS FOR PROJECT 2
ZX_LOCAL_BASE="/var/PROJECT2/folder"
ZX_LOCAL_ORIG="$ZX_LOCAL_BASE/`date +%Y`"
ZX_LOCAL_DEST="/backup/PROJECT2/folder"

#Usage function (Help)
function usage(){
    echo "Usage: ./$SELF [OPTIONS]
Backup .zip~ files and add a symbolic link in the origin folder

Mandatory arguments (Should be one of these -zx or -zc).
    -zc    Backup zip files of PROJECT1
    -zx    Backup zip files of PROJECT2

Optionals (If you will not use -zc or -zx).
    -o --origin PATH    Source path (If you send this option you must send the destination too)
    -d --destination PATH Destination path (If you send this option you must send the origin too)
    -h --help    Show this help text

Examples.
    ./$SELF -zc
    ./$SELF -zx
    ./$SELF -o /home/folder -d /backup/folder
"
}

function process(){
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Is mandatory send origin and destination. 
              E.g ./$SELF -o /origin -d /destination"
        exit
    fi
    [[ $3 = 'zx' ]] && ZX="-o -name '*zip'"
    echo "find $1 -type f -name '*.zip~' $ZX | grep -v filepart"
    FILES=`find $1 -type f -name '*.zip~' $ZX | grep -v filepart`
    for file in $FILES; do
        local suffix=""
        if [[ $file == *$ZX_LOCAL_BASE* ]]; then
           suffix=`echo $file | sed 's|'$ZX_LOCAL_BASE'/||'`
           suffix="/`dirname $suffix`"
        fi
        echo "Moving $file to $2$suffix/`basename $file`"
        mkdir -p $2$suffix
        mv $file $2$suffix/`basename $file`
        ln -s $2$suffix/`basename $file` $file
    done
    echo "Done ;) ... have a good day!"
}

if [ -z "$1" ]; then
    usage
    exit
fi

while [ "$1" != "" ]; do
    case $1 in
        -zc )		shift
			CUSTOM=false
			echo "PROCESSING 'PROJECT1'"
			process $ZC_LOCAL_ORIG $ZC_LOCAL_DEST
			exit
			;;
        -zx )		shift
			CUSTOM=false
			echo "PROCESSING 'PROJECT2'"
			process $ZX_LOCAL_ORIG $ZX_LOCAL_DEST 'zx'
			exit
			;;
        -o )		shift
			CUSTOM=true
			ORIGIN=$1
			;;
        -d )		shift
			CUSTOM=true
			DESTINATION=$1
			;;	
        -h | --help )	usage
			exit
			;;
        * )		usage
			exit 1
    esac
    shift
done

if [ -z "$ORIGIN" ] || [ -z "$DESTINATION" ]; then
    echo "Is mandatory send origin and destination. 
          E.g ./$SELF -o /origin -d /destination"
    exit
else
    process $ORIGIN $DESTINATION
fi

