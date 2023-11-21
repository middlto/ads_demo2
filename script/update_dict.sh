#!/bin/bash

event_day=`date +"%Y%m%d"`
event_hour=`date +"%H"`
remove_day=`date -d "${event_day} 5 days ago" +"%Y%m%d"`

turing="./hadoop"
turing_path="userpath.bes_cmatch_appsid_tu_apkname_dict.txt"
apk_info_dir="../data/store_apk_info"

vivo_apk_info="${apk_info_dir}/vivo/vivo_app_info.txt"
vivo_dict="${apk_info_dir}/vivo/vivo_cmatch_appsid_tu_apkname_dict.txt"
vivo_backup_dict="${apk_info_dir}/vivo/backup/vivo_cmatch_appsid_tu_apkname_dict.txt.${event_day}${event_hour}"
xiaomi_apk_info="${apk_info_dir}/xiaomi/xiaomi_app_info.txt"
xiaomi_dict="${apk_info_dir}/xiaomi/xiaomi_cmatch_appsid_tu_apkname_dict.txt"
xiaomi_backup_dict="${apk_info_dir}/xiaomi/backup/xiaomi_cmatch_appsid_tu_apkname_dict.txt.${event_day}${event_hour}"
oppo_apk_info="${apk_info_dir}/oppo/oppo_app_info.txt"
oppo_dict="${apk_info_dir}/oppo/oppo_cmatch_appsid_tu_apkname_dict.txt"
oppo_backup_dict="${apk_info_dir}/oppo/backup/oppo_cmatch_appsid_tu_apkname_dict.txt.${event_day}${event_hour}"
huawei_apk_info="${apk_info_dir}/huawei/huawei_app_info.txt"
huawei_dict="${apk_info_dir}/huawei/huawei_cmatch_appsid_tu_apkname_dict.txt"
huawei_backup_dict="${apk_info_dir}/huawei/backup/huawei_cmatch_appsid_tu_apkname_dict.txt.${event_day}${event_hour}"
manual_blacklist="../data/manual_data/manual_blacklist.txt"
apk_whitelist="../data/manual_data/apk_whitelist.txt"
total_dict="../data/bes_cmatch_appsid_tu_apkname_dict.txt"

vivo_backup_dir="${apk_info_dir}/vivo/backup"
xiaomi_backup_dir="${apk_info_dir}/xiaomi/backup"
oppo_backup_dir="${apk_info_dir}/oppo/backup"
huawei_backup_dir="${apk_info_dir}/huawei/backup"

# vivo
grep -vf ${apk_whitelist} ${vivo_apk_info} > ${vivo_apk_info}.new
awk '{if($2=="2" || $2=="3"){print "713\tvivo_id1\t*\t"$1;print "713\tvivo_id2\t*\t"$1;print "713\tvivo_id3\t*\t"$1;}}' ${vivo_apk_info}.new > ${vivo_dict}
cp ${vivo_dict} ${vivo_backup_dict}

# xiaomi
grep -vf ${apk_whitelist} ${xiaomi_apk_info} > ${xiaomi_apk_info}.new
awk '{if($2=="3"){print "713\txiaomi_id1\t*\t"$1;print "713\txiaomi_id2\t*\t"$1;print "713\txiaomi_id3\t*\t"$1;}}' ${xiaomi_apk_info} > ${xiaomi_dict}
cp ${xiaomi_dict} ${xiaomi_backup_dict}

# oppo
grep -vf ${apk_whitelist} ${oppo_apk_info} > ${oppo_apk_info}.new
awk '{if($2!="1"){print "713\toppo_id1\t*\t"$1;print "713\toppo_id2\t*\t"$1;print "713\toppo_id3\t*\t"$1;}}' ${oppo_apk_info} > ${oppo_dict}
cp ${oppo_dict} ${oppo_backup_dict}

# huawei
grep -vf ${apk_whitelist} ${huawei_apk_info} > ${huawei_apk_info}.new
awk '{if($2!="1"){print "713\thuawei_id1\t*\t"$1;print "713\thuawei_id2\t*\t"$1;print "713\thuawei_id13\t*\t"$1;}}' ${huawei_apk_info} > ${huawei_dict}
cp ${huawei_dict} ${huawei_backup_dict}

# merge
sort ${vivo_dict} ${xiaomi_dict} ${oppo_dict} ${huawei_dict} ${manual_blacklist} | uniq > ${total_dict}

# upload
${turing} fs -test -e ${turing_path}
if [[ $? -eq 0 ]]
then
    ${turing} fs -rmr ${turing_path}
fi
${turing} fs -put ${total_dict} ${turing_path}

# clear history
for file in `ls ${vivo_backup_dir} | grep "${remove_day}"`
do
    rm ${vivo_backup_dir}/${file}
done

for file in `ls ${xiaomi_backup_dir} | grep "${remove_day}"`
do
    rm ${xiaomi_backup_dir}/${file}
done

for file in `ls ${oppo_backup_dir} | grep "${remove_day}"`
do
    rm ${oppo_backup_dir}/${file}
done

for file in `ls ../logs | grep "update" | grep "${remove_day}"`
do
    rm ../logs/${file}
done

