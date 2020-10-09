#!/bin/bash

td=$(date +%Y%m%d) 
chg="false"

# diff report function to repeat the same task for device type
diff_report() 
{
    vendor=$1
    cd /config/$vendor
    while d= read -r line
    do
        last=$(ls -t1 | grep $line | head -1)
        if [ -f "$last" ]; then
            if [ $vendor == huawei ]; then
                unzip -q $last -d /scripts/temp
                mv /scripts/temp/vrpcfg.cfg /scripts/temp/$line
            else
                cp $last /scripts/temp/$line
            fi

            if [ ! -f /scripts/baseline/$line ]; then
                cp /scripts/temp/$line /scripts/baseline/$line
            else
                if [ $vendor == mikrotik ]; then
                    diff -u <(tail -n +2 /scripts/baseline/$line) <(tail -n +2 $last) 1>/dev/null
                else
                    diff -u /scripts/baseline/$line /scripts/temp/$line 1>/dev/null
                fi     
                
                if [ ! $? == "0" ]; then
                    cp /scripts/baseline/$line /scripts/temp/$line-$td-before
                    cd /scripts/temp/
                    gpg --yes --always-trust -e -r "itmatic101" $line-$td-before
                    zip -q /diff_reports/changelog_$td.zip $line-$td-before.gpg; cd - 1> /dev/null;
                    
                    echo -e "\n$line changelog:" &>> /diff_reports/changelog_$td.log
                    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" &>> /diff_reports/changelog_$td.log
                    if [ $vendor == mikrotik ]; then
                        diff -u <(tail -n +2 /scripts/baseline/$line) <(tail -n +2 $last) &>> /diff_reports/changelog_$td.log
                    else    
                        diff -u /scripts/baseline/$line /scripts/temp/$line &>> /diff_reports/changelog_$td.log
                    fi
                    echo -e "\n###############################################################" &>> /scripts/diff_reports/changelog_$td.log
                    
                    cp /scripts/temp/$line /scripts/baseline/$line
                    cp /scripts/baseline/$line /scripts/temp/$line-$td-after
                    cd /scripts/temp/
                    gpg --yes --always-trust -e -r "itmatic101" $line-$td-after
                    zip -q /diff_reports/changelog_$td.zip $line-$td-after.gpg; cd - 1> /dev/null;
                    chg="true"
                fi
            fi
        fi
    done < /scripts/inventory/$vendor
}

for arg in cisco hpe fortigate huawei mikrotik
do
    diff_report $arg
done

if [ "$chg" == true ]; then
    echo change change
    cd /diff_reports/
    gpg --yes --always-trust -e -r "itmatic101" changelog_$td.log
    zip -q changelog_$td.zip changelog_$td.log.gpg
    echo "Config Changelog for $td" | mailx -s "Config Changelog Report $td" -a "/diff_reports/changelog_$td.zip" tyla@itmatic101.com

    # replicate the baseline to latest in config
    rsync -azh /scripts/baseline/ /config/latest/

    # git auto version control on /config/latest/
    cd /config/latest/
    git add *
    git commit -am "auto commit for $td"
    git push origin master
fi      

# cleanup unnecessary files 
rm /scripts/temp/* 2> /dev/null
rm /diff_reports/*.zip 2> /dev/null
rm /diff_reports/*.gpg 2> /dev/null