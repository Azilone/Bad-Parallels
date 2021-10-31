#Setup pswd and date
Setup(){
    get_root(){
        sudo -k
        pswd=$(osascript -s o -e 'display dialog "Enter your Mac password : " with hidden answer default answer "" with title "Setup" with icon POSIX file "icon/Lock.icns"' -e 'text returned of result')
        if [[ "$pswd" == *"-128"* ]]; then
            exit
        fi
        echo $pswd | sudo -S -v 
        verify_root=$?

        while [[ $verify_root != 0 ]];do
            pswd=$(osascript -s o -e 'display dialog "Bad password try again : " with hidden answer default answer "" with title "Setup" with icon POSIX file "icon/Lock.icns"' -e 'text returned of result')
            if [[ "$pswd" == *"-128"* ]]; then
                exit
            fi
            echo $pswd | sudo -S -v 
            verify_root=$?
        done
        pswd=$(echo $pswd | openssl aes-256-cbc -a -salt -pass pass:pswd)
    }
    get_root
    echo $pswd > info.txt


    ref_date=$(osascript -s o -e 'display dialog "Enter your reference date (exemple : 22/09/21 for 22 september 2021) " default answer "" with title "Setup" with icon POSIX file "icon/Calendar.icns"' -e 'text returned of result' | tr -d '/')
    if [[ "$ref_date" == *"-128"* ]]; then
        exit
    fi
    while [[ ${#ref_date} != 6 ]];do
        ref_date=$(osascript -s o -e 'display dialog "Incorrect date or syntax (exemple 22/09/21 for 22 september 2021) " default answer "" with title "Setup" with icon POSIX file "icon/Calendar.icns"' -e 'text returned of result' | tr -d '/')
        if [[ "$ref_date" == *"-128"* ]]; then
                exit
        fi
        echo ${#ref_date}
    done
    current_time=$(date +%H%M)
    fake_date=${ref_date:0:4}${current_time}${ref_date:4:6}

    echo $ref_date >> info.txt
    setup_status=true
}

if [[ $(wc -l < info.txt | tr -d ' ') != 2 ]];then
    Setup
fi


#Verify if parallels running
is_running(){
	check_run=$(ps aux | grep "/Applications/Parallels Desktop" | wc -l | sed 's/ //g')
		if [[ $check_run > 2 ]]; then
			check_run=true
		else
			check_run=false
		fi
}
is_running
if [[ $check_run == true ]]; then
	response=$(osascript -e 'display dialog "Parallels is already running " buttons {"Restart Parallels","Exit"} with icon cautioncd ' -e 'button returned of result')
fi
if [[ $response == 'Exit' ]]; then
	exit
else
	osascript -e 'quit app "Parallels Desktop"'
	sleep 3
fi

#get sudo
secret=$(sed '1!d' info.txt)
echo $secret | openssl aes-256-cbc -d -a -pass pass:pswd | sudo -S -v

#change to fake date
ref_date=$(sed '2!d' info.txt)
current_time=$(date +%H%M)
ref_date=${ref_date:2:2}${ref_date:0:2}${current_time}${ref_date:4:6}
sudo date $ref_date


open -a 'Parallels Desktop'
if [[ $? != 0 ]];then
        osascript -s o -e 'display dialog "Check if Parallels Desktop is installed on your Mac " with title "Setup" with icon caution'
		sudo systemsetup -setnetworktimeserver apple.com
		exit
fi


open Date.app
#When parallels stop put the actual date
while true;do 
	sleep 10
    echo $secret | openssl aes-256-cbc -d -a -pass pass:pswd | sudo -S -v
	is_running
	if [[ $check_run == false ]];then
		sudo systemsetup -setnetworktimeserver apple.com
        killall Date
        exit
	fi
done