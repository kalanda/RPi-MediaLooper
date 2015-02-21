#!/bin/bash
if pgrep omxplayer; then
  echo "Stopping"
  pkill omxplayer
  pkill videoloop
  exit;
fi

# Variables
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
MEDIA_PATH=/media/usb
AUDIO_OUTPUT=hdmi # hdmi or local

# External config
if [ -f $MEDIA_PATH/config.txt ]; then
  source $MEDIA_PATH/config.txt
fi

# Variables
MEDIA_PATH=/media/usb
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Hide terminal
setterm -cursor off
setterm -foreground black
setterm -clear

onExit()
{
  setterm -cursor on
  setterm -foreground white -clear
  IFS=$SAVEIFS
  exit $?
}

# trap keyboard interrupt (control-c)
trap onExit SIGINT

# infinite loop
while true; do
 if pgrep omxplayer; then
  pkill omxplayer
  sleep 1;
 else
  # For each video
  for f in `ls $MEDIA_PATH | grep ".mp4$\|.avi$\|.mkv$\|.mp3$\|.mov$\|.mpg$\|.flv$\|.m4v$\|.divx$"`; do
     omxplayer -b --no-keys --no-osd -o $AUDIO_OUTPUT "$MEDIA_PATH/$f"
  done
 fi
done

# Things to do on exit
onExit


