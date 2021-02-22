#!/bin/bash
# image28 (2021)
# Scrapped look into Autobuilding code and correcting compile errors withouth modifying the packages code
# Original started it to cross compile xmrig for Xeon Phi without cmake and autotools
# Place in the xmrig/src folder to watch it fail to compile.
# Will add earlier version and some of the Phi based code in the same repo for now.


IFS=$'\n'
WORKING="`pwd`"
CFLAGS="-DXMRIG_OS_LINUX -D_GNU_SOURCE -DHAVE_ROTR -DXMRIG_FEATURE_ASM -DRAPIDJSON_SSE2 -DXMRIG_ALGO_ASTROBWT -DUSE_ASM -DXMRIG_ALGO_ARGON2 -DDXMRIG_ALGO_CN_PICO -DDXMRIG_ALGO_CN_HEAVY -DXMRIG_ALGO_CN_LITE -DXMRIG_ALGO_RANDOMX -DXMRIG_FIX_RYZEN -DXMRIG_FEATURE_MSR -DXMRIG_OS_LINUX -DXMRIG_FEATURE_TLS -DXMRIG_FEATURE_ASM -DXMRIG_ALGO_KAWPOW -DXMRIG_MINER_PROJECT -DXMRIG_FEATURE_SSE4_1 -DXMRIG_JSON_SINGLE_LINE_ARRAY -D__STDC_FORMAT_MACROS -D_FILE_OFFSET_BITS=64 -Ofast -march=native -mtune=native -m64 -mavx2 "
CXXFLASG="$CFLAGS"
INCLUDE_DIR="-I/usr/include -I$WORKING -I$WORKING/3rdparty"
CXXLIBS="-c -Ofast -march=native -mtune=native -m64 -mavx2 -std=c++17 -lm -lhwloc -lrt -ldl -lpthread -luv -lcrypto -lssl"
CLIBS="-lm -lhwloc -lrt -ldl -lpthread -luv -lcrypto -lssl"
ASLIBS="-c"
CXX=g++
CC=gcc 
AS=gcc
SKIP="(win|IOKit|mac|arm|unix|opencl|bench|api|cuda|http|a64)" #"(win|hwloc|mac|arm|test)"
ERRFILE=".current.errors"
echo "$INCLUDE_DIR"

function compile-group()
{
	FILES="`find $WORKING -name "*.$1" -print| grep -vEi \"$SKIP\"`"
	if test $1 == "cpp";
	then
		BIN=$CXX;
		FLAGS=$CXXFLAGS
		LIBS=$CXXLIBS
		EXTRA="-o"
	elif test $1 == "S";
	then
		BIN=$AS
		FLAGS=$ASFLAGS
		LIBS=$ASLIBS
		EXTRA="-o"
	elif test $1 == "c";
	then
		BIN=$CC;
		FLAGS=$CFLAGS
		LIBS=$CLIBS
		EXTRA="-o"
	fi
	
	echo "Compiling files with $BIN..."
	for d in $FILES;
	do	
		echo "$d"
		OUTPUT="`echo \"$d\" | sed -e s/\".$1\"/\".o\"/`"
		#echo "$BIN $EXTRA \"$OUTPUT\" $INCLUDE_DIR $FLAGS $d $LIBS 2> $ERRFILE"
		$BIN $INCLUDE_DIR $EXTRA "$OUTPUT" $FLAGS $d $LIBS 2> $ERRFILE
		ERRORCODE="$?"
		#echo "Return: $ERRORCODE"
		if test $ERRORCODE -ne 0;
		then
			if test $ERRORCODE -eq 1;
			then
				SEARCHPATH="`echo $d| rev | cut -d'/' -f2- | rev | tr -d '\n'`"
				INCLUDE="`cat $ERRFILE | head -n2 | tail -n1 | rev | awk -F':' '{print $2}' | rev`"
				BASE="`basename $INCLUDE | tr -d '\n'`"
				echo "Searching near $SEARCHPATH for include file $BASE ($INCLUDE)"
				FILECOUNT=`find "$SEARCHPATH" -name "$BASE" -print 2> /dev/null | wc -l`
				if test $FILECOUNT -eq 0
				then
					echo "Searching from project root"
					find "$WORKING" -name "$BASE" -print
					FILECOUNT=`find "$WORKING" -name "$BASE" -print 2> /dev/null | wc -l`
				fi
				exit
			else
				FILE="`cat $ERRFILE | head -n2 | tail -n1 | awk -F':' '{print $1}' | rev | awk -F'/' '{print $1}' | rev | tr -d '\n'`"
				LINE="`cat $ERRFILE | head -n2 | tail -n1 | awk -F':' '{print $2}' | tr -d '\n'`"
				CHAR="`cat $ERRFILE | head -n2 | tail -n1 | awk -F':' '{print $3}' | tr -d '\n'`"
				echo
				echo "Errorcode $ERRORCODE on line $LINE at character $CHAR in file $FILE, currently not autocorrectable, exiting.."
				echo
				sleep 1
				cat .current-errors
				exit;
			fi
		fi
	done
}

compile-group S
compile-group c
compile-group cpp
