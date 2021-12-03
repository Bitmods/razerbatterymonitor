#!/bin/bash

#### Replace 'MYUSERNAME' with your user name.

#### Program is scheduled to run every X minutes with crontab but needs to define new env variables to
#### resolve "Unable to autolaunch a dbus-daemon without a $DISPLAY for X11" error when executing
#### 'openrazer.client.DeviceManager()' in cron, due to limited cron environment (using Pop!_OS 21.04).

#SHELL=/bin/bash
#PATH=/home/MYUSERNAME/.local/bin:/home/MYUSERNAME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin
#DISPLAY=:1
#PID=$(pgrep -o gnome-session)
#export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)
#XAUTHORITY=/home/MYUSERNAME/.Xauthority


#Select which devices to poll for battery status. [0] returns all my razer devices (basilisk mouse + dock)
razerstatus="$(python3 -c "import openrazer.client; a = openrazer.client.DeviceManager().devices[0]; print(a.is_charging, a.battery_level)")"
is_charging="$(echo "${razerstatus}" | cut --delimiter=' ' --fields=1 -)"
battery_level="$(echo "${razerstatus}" | cut --delimiter=' ' --fields=2 -)"


#[0]=Red, [50]=Yellow, [100]=Green, [101-110]-prevents array going out of bounds
colour_chart=("FF0000"\
    "FF0000" "FF0000" "FF0000" "FF0000" "FF0000" "FF0500" "FF0A00" "FF0F00" "FF1400" "FF1900"\
    "FF1E00" "FF2300" "FF2800" "FF2D00" "FF3200" "FF3700" "FF3C00" "FF4100" "FF4600" "FF4B00"\
    "FF5000" "FF5500" "FF5A00" "FF5F00" "FF6400" "FF6900" "FF6E00" "FF7300" "FF7800" "FF7D00"\
    "FF8200" "FF8700" "FF8C00" "FF9100" "FF9600" "FF9B00" "FFA000" "FFA500" "FFAA00" "FFAF00"\
    "FFB400" "FFB900" "FFBE00" "FFC300" "FFCD00" "FFD700" "FFEB00" "FFF500" "FFFF00" "FAFF00"\
    "F5FF00" "F0FF00" "EBFF00" "E6FF00" "E1FF00" "DCFF00" "D7FF00" "D2FF00" "CDFF00" "C8FF00"\
    "C3FF00" "BEFF00" "B9FF00" "B4FF00" "AFFF00" "AAFF00" "A5FF00" "A0FF00" "9BFF00" "96FF00"\
    "91FF00" "8CFF00" "87FF00" "82FF00" "7DFF00" "78FF00" "73FF00" "6EFF00" "69FF00" "64FF00"\
    "5FFF00" "5AFF00" "55FF00" "50FF00" "4BFF00" "46FF00" "41FF00" "3CFF00" "37FF00" "32FF00"\
    "2DFF00" "28FF00" "23FF00" "1EFF00" "19FF00" "14FF00" "0FFF00" "0AFF00" "05FF00" "00FF00"\
    "00FF00" "00FF00" "00FF00" "00FF00" "00FF00" "00FF00" "00FF00" "00FF00" "00FF00" "00FF00"\
    )

#Charging       - Brightness 100%   Dual colour breathing between % colour and %+10 colour.
#Full Charge    - Brightness 100%   Static Green
#Normal use     - Brightness 50%    Static colour of battery %
#Low battery    - Brightness 5%     Dual colour breathing between maroon/purple
if [ $is_charging = 'True' ]; then
    if [ $(("${battery_level}")) -eq 100 ]; then
        /usr/bin/polychromatic-cli -o brightness -p 100
        /usr/bin/polychromatic-cli -o static -c ${colour_chart[100]}
    else
        /usr/bin/polychromatic-cli -o brightness -p 100
        /usr/bin/polychromatic-cli -o breath -p dual -c ${colour_chart[${battery_level}]},${colour_chart[$(( ${battery_level} + 10 ))]}
    fi
elif [ $(("${battery_level}")) -le 5 ]; then 
    /usr/bin/polychromatic-cli -o brightness -p 5
    /usr/bin/polychromatic-cli -o breath -p dual -c FF0020,2000FF
else
    /usr/bin/polychromatic-cli -o brightness -p 50
    /usr/bin/polychromatic-cli -o static -c ${colour_chart[${battery_level}]}
fi