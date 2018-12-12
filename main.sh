#!/bin/bash

#IPMI test tool    by nickli 2018.12.11
echo -e "\033[31mThis tool use \"ipmitool -I lanplus \". So do not use this tool in your IPMI local server OS. \033[0m"
echo ""
fping -v
if [ $? -ne 0 ];
then
    echo "Please install fping first."
    exit 14
fi

ipmitool -V
if [ $? -ne 0 ];
then
    echo "Please install ipmitool first."
    exit 14
fi

echo ""
echo "Enter IPMI search start address (e.g. 10.10.162.1): "
read startadr

echo "Enter IPMI search end address (e.g. 10.10.162.255): "
read endadr

#echo $startadr
echo "Searching, please wait..."

fping -a $startadr $endadr -g > search.log 2>/dev/null

if  [ ! -s "search.log" ];                                      #判断文件是否为空
then
    echo "Cannot find any available IP target! Please check."
    rm search.log
    exit 15
fi

echo "Enter IPMI username: "
read ipmiusername

echo "Enter IPMI password: "
read ipmipassword

echo "Check available ipmi server. Please wait..."
cat search.log | while read line
do
    #echo "$line test"
    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword chassis status &>/dev/null
    if [ $? -eq 0 ];
    then
        echo $line > ipmiavailable.log
    fi
done 

if  [ ! -f "ipmiavailable.log" ];                              #判断文件是否存在
then
    echo "Cannot find any available IPMI server! Please check."
    rm search.log
    exit 15
fi

echo "Start IPMI test. Please wait..."
cat ipmiavailable.log | while read line
do
    touch $line.log
    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword chassis status &>> ./$line.log
    echo "ipmichassisstatus: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword user list &>> ./$line.log
    echo "ipmiuserlist: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword power status &>> ./$line.log
    echo "ipmipowerstatus: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword sensor &>> ./$line.log
    echo "ipmisensor: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword sdr info &>> ./$line.log
    echo "ipmisdrinfo: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword sdr list &>> ./$line.log
    echo "ipmichassisstatus: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword sdr list fru &>> ./$line.log
    echo "ipmisdrlistfru: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword fru &>> ./$line.log
    echo "ipmifru: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword power reset &>> ./$line.log
    echo "ipmipowerreset: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log
    sleep 5m

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword power off &>> ./$line.log
    echo "ipmipoweroff: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log
    sleep 5m

    ipmitool -I lanplus -H $line -U $ipmiusername -P $ipmipassword power on &>> ./$line.log
    echo "ipmipoweron: "$? | tee -a ./$line.log
    echo "--------------------------------" | tee -a ./$line.log

    mv $line.log $line"@"`date "+%x-%T"`.log
done 



rm search.log
rm ipmiavailable.log