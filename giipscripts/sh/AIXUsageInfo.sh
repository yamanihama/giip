#!/bin/bash
# Written by Lowy Shin at 20160627

# System Variables ===============================================
sk="{{sk}}"
lssn="{{lssn}}"

# User Variables ===============================================
factor="Cpu,Mem,Disk Usage"
#CPU 사용률 점검 
CU=`sar 1 5 | grep "Average" | awk '{print $2}'`


# Real Memory 점검
# 전체 메모리에서 FreeSize를 제거한 메모리를 퍼센테이지화 한다.
# 계산방법: 100 - ( ( FreeSize / TotSize ) * 100
MU=`svmon -G |grep memory |perl -ane 'printf"%0.1f \n", 100 - ( ( $F[3] / $F[1] ) * 100 ) '`


#DISK 사용률 점검
#root 디렉토리에 마운트되어진 디스크 사용량에 따라 서버의 상태를 확인할 수 있다.
DU=`df -k | head -2 | tail -1 | awk '{print $4}' |sed 's/\%//g'`

valueJSON=`awk '{print "{\"CPUUsage\":\""$MU"\",\"MemoryUsage\":\""$2"\",\"\":\""$3"\"}"}' verInfo`
valueJSON="{\"$factor\":[ $valueJSON ]}" 

# Send Command ==================================================
#<!MEANINGLESS!> rm -f /var/log/lsyncd/lsyncd.log-*

# Send to KVSAPI Server =========================================
qs="sk=$sk&type=lssn&key=$lssn&factor=$factor&value=$valueJSON"
wget "http://giip.littleworld.net/API/kvs/put?$qs" -O "giipapi.log"

rm -f giipapi.log
rm -f put?*
