#!/bin/bash

if [[ $# -eq 2 ]]
then
    event_day=$1
    event_hour=$2
else
    event_day=`date +"%Y%m%d"`
    event_hour=`date -d "1 hours ago" +"%H"`
fi

# get hour data
hadoop="./hadoop"
dump_path=""
local_path="../data/apk_data/apk_data_dump/${event_day}${event_hour}.txt"
tables=("PlanTable.txt.formated")
apk_table="../data/apk_data/apk_table_dump.txt"

if [[ -a ${local_path} ]]
then
    rm ${local_path}
fi

for share in {0..3}
do
    for table in ${tables[@]}
    do
        ${hadoop} fs -test -e ${dump_path}/${share}/${event_day}/${event_hour}/${table}.donefile
        if [[ $? -eq 0 ]]
        then
            ${hadoop} fs -cat ${dump_path}/${share}/${event_day}/${event_hour}/${table} | awk -F '\x01\x01' '{if($4!=""&&$4!="NULL"&&$5!=""&&$5!="NULL"&&$5!="0"){print $4"\thttps://cover.com/cover/deeplink_android?downloadUrl="$5"&ssl=1"}}' >> ${local_path}
        fi
    done
done

# remove history
apk_table_dir="../data/apk_data/apk_data_dump"
log_dir="../logs"
remove_day=`date -d "${event_day} 1 days ago" +"%Y%m%d"`
for file in `ls ${apk_table_dir} | grep "${remove_day}${event_hour}"`
do
    rm ${apk_table_dir}/${file}
done

for file in `ls ${log_dir} | grep "dump" | grep "${remove_day}"`
do
    rm ${log_dir}/${file}
done

# generate apk_table
cat ${apk_table_dir}/* | awk '{print}' | sort | uniq > ${apk_table}.tmp
mv ${apk_table}.tmp ${apk_table}

# merge
apk_table_eshow="../data/apk_data/apk_table_eshow.txt"
final_apk_table="../data/apk_data/apk_table.txt"
sort ${apk_table_eshow} ${apk_table} | uniq > ${final_apk_table}.tmp
mv ${final_apk_table}.tmp ${final_apk_table}
