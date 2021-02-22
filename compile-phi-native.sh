#!/bin/bash

#IFS=$'\n'; 
UV_INC="/home/image/Downloads/libuv/include/"
. /opt/mpss/3.8.6/environment-setup-k1om-mpss-linux
FLAGS=""
export LD="/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-ld"
export AS="/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-as"
export AR="/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-ar"
export NM="/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-nm"
export OBJDUMP="/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-objdump"
export OBJCOPY="/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-objcopy"
export RANLIB="/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-ranlib"
export CC="/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-gcc"
export STRIP="/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-strip"

SKIP="(win|hwloc|mac|arm)"
FILES="`ls crypto/common/*.{h,cpp} | grep -vEi  "$SKIP" && \
	ls crypto/rx/*.{h,cpp} | grep -vEi  "$SKIP" && \
	ls core/config/*.{h,cpp} && \
	ls core/*.{h,cpp} && \
	ls net/*.{h,cpp} && \
	ls base/io/log/*.{h,cpp} | grep -vEi  "$SKIP" && \
	ls base/io/json/*.{h,cpp} | grep -vEi  "$SKIP" && \
	ls base/kernel/config/*.{h,cpp} | grep -vEi  "$SKIP" && \
	ls base/kernel/*.{h,cpp} | grep -vEi  "$SKIP" && \
	ls base/net/{dns,http,https,stratum,tls,tools}/*.{h,cpp} && \
	ls base/{crypto,io,tools}/*.{h,cpp} && \
	ls backend/common/*.{h,cpp} && \ 
	ls backend/cpu/platform/*.{h,cpp} | grep -vEi  "$SKIP" && \
	ls backend/cpu/*.{h,cpp} && \
	ls *.{h,cpp} | grep -vEi "$SKIP"`"

OUTPUT="xmrig"

echo "Compiling"
echo "$FILES" | tr '\n' ' '
for d in `$FILES`; do
	${CXX}  -c -o $OUTPUT -m64 -mavx512f -lm -lopenssl -O3 -std=c++11 -I/usr/include -I./ -I$UV_INC $LIBS $d
done
LIBS="`echo $FILES | grep -Ei "*.cpp"`"
${CXX} -o $OUTPUT --sysroot=/opt/mpss/3.8.6/sysroots/k1om-mpss-linux -m64 -mavx512f -lm -lopenssl -O3 -std=c++11 -I/usr/include -I./ -I$UV_INC $LIBS 
