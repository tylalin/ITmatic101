#!/bin/bash

td=$(date +%Y%m%d)
touch /backup_reports/backup_report_"$td".csv
echo "Network Device Name","Last Config Backup File","File Age","Status" > /backup_reports/backup_report_"$td".csv

# backup report function to repeat the same task for device type
backup_report() 
{
    vendor=$1
    cd /configs/$vendor
    while d= read -r line
    do
        last=$(ls -t1 | grep $line | head -1)
        if [ -f "$last" ]; then
            fd=$(date +%s -r $last)
            cd=$(date +%s)
            diff=`expr $cd - $fd`
            if [ "$diff" -gt 864000 ]; then 
                echo "$line","$last","$(($diff / 86400)) day(s) old","Warning"  >> /backup_reports/backup_report_"$td".csv
            else 
                echo "$line","$last","$(($diff / 86400)) day(s) old","Pass"  >> /backup_reports/backup_report_"$td".csv
            fi
        else
            echo "$line","File Not Found","Haven't run backup for this device yet","Fail"  >> /backup_reports/backup_report_"$td".csv
        fi
    done < /scripts/inventory/$vendor
}

for arg in cisco hpe fortigate huawei mikrotik
do
    backup_report $arg
done

echo "Weekly Config Backup Report for $td" | mailx -s "Backup Report $td" -a "/backup_reports/backup_report_"$td".csv" tyla@itmatic101.com