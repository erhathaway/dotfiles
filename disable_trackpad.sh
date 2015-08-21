f [ "$getstatus" == "1" ]; then
newstatus="0"
zenity --info --text="Touchpad OFF" --timeout 1
else
newstatus="1"
zenity --info --text="Touchpad ON" --timeout 1
fi

