#!/bin/bash

if [[ $# -eq 1 ]]
then
    event_day=$1
else
    event_day=`date -d "1 days ago" +"%Y%m%d"`
fi

# get turing result
turing="./hadoop"
turing_path="userpath.apk_name_eshow/${event_day}"
local_path="../data/apk_data/apk_data_eshow/${event_day}.txt"

retry_num=282
while [[ ${retry_num} -gt 0 ]]
do
    retry_num=`expr ${retry_num} - 1`
    ${turing} fs -test -e ${turing_path}/_SUCCESS
    if [[ $? -eq 0 ]]
    then
        if [[ -a ${local_path} ]]
        then
            rm ${local_path}
        fi
        ${turing} fs -test -e ${turing_path}/_temporary
        if [[ $? -eq 0 ]]
        then 
            ${turing} fs -rmr ${turing_path}/_temporary
        fi
        ${turing} fs -getmerge ${turing_path} ${local_path}
        break
    fi
    sleep 300
done

# delete history
apk_table_dir="../data/apk_data/apk_data_eshow"
log_dir="../logs"
remove_day=`date -d "${event_day} 5 days ago" +"%Y%m%d"`
for file in `ls ${apk_table_dir} | grep "${remove_day}"`
do
    rm ${apk_table_dir}/${file}
done

for file in `ls ${log_dir} | grep "eshow" | grep "${remove_day}"`
do
    rm ${log_dir}/${file}
done

# generate apk_table
apk_table="../data/apk_data/apk_table_eshow.txt"
cat ${apk_table_dir}/* | awk '{domain=substr($4,9,15);if(domain=="cover.com"){print $2"\t"$4}}' | sort | uniq > ${apk_table}.tmp
mv ${apk_table}.tmp ${apk_table}

