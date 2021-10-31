cd ../../../
#get sudo
secret=$(sed '1!d' info.txt)
echo $secret | openssl aes-256-cbc -d -a -pass pass:pswd | sudo -S -v

#change to fake date
ref_date=$(sed '2!d' info.txt)
current_time=$(date +%H%M)
ref_date=${ref_date:2:2}${ref_date:0:2}${current_time}${ref_date:4:6}


hour_choose=$(osascript -s o -e 'display dialog "Change the date" buttons {"Current date", "Fake date","Exit"} with title "Date changer" with icon POSIX file "icon/Calendar.icns"' -e 'button returned of result')
if [[ $hour_choose == "Fake date" ]];then
    sudo date $ref_date
elif [[ $hour_choose == "Current date" ]];then
    sudo systemsetup -setnetworktimeserver apple.com
elif [[ $hour_choose == "Exit" ]];then
    exit
fi