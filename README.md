RPi-MediaLooper
===============
Automatic looper for video or audio useful for digital posters and audiovisual installations using *Raspberry Pi* hardware. 

- Looks for files stored in a USB device
- Recognized file extensions .mp4, .avi, .mkv, .mp3, .mov, .mpg, .flv, .m4v and .divx
- Audio output is set by default to HDMI but is configurable via *config.txt* file placed on USB root
- Automatic startup without user intervention when device is powered on
- If more than one file is found will play all in alphabet order and start again

## Overview

This project is based in only one script that runs on a *Raspbian* installation. The script will check all files inside the storage device connected to USB port (mounted at `/media/usb`) and make calls to `omxplayer` to play each supported file in a endless loop (you can press CTRL-C to cancel). 

Code and ideas are taken from other projects listed below at the end of this document. 

## Installation instructions

For the installation you need:

- SD Card 4 Gb or more
- USB storage device like a pendrive or a portable hard disk.
- USB keyboard (only during installation) 
- Ethernet cable for internet access using your local network (only during installation)

### Step 1. Install Raspbian. 

[Download](http://www.raspberrypi.org/downloads/) the lastest version of Raspbian and install following the [installation instructions](http://www.raspberrypi.org/documentation/installation/installing-images/README.md
) to create your SD card with the Raspbian system.

### Step 2. Expand filesystem
First time you boot the fresh Raspbian installation, the `raspi-config` menu will appear and you must choose "Expand filesystem" to make usable all the free space in SD card. There are some other options you can change here but are not required for this project. 

**NOTE:** You can always open this utility again by typing `sudo raspi-config` at command line

### Step 3. Fix locale warnings
Some warnings referring to locale appears when installing some packages. To fix this you have to edit `/etc/default/locale` file:

	sudo nano /etc/default/locale

Put that:

	LANG=en_GB.UTF-8
	LC_ALL=en_GB.UTF-8
	LANGUAGE=en_GB.UTF-8
	
When is done, press CTRL-O and ENTER to save and CTRL-X to exit.

### Step 4. Update and upgrade packages
First at all, you have to update and upgrade packages:

	sudo apt-get update
	sudo apt-get upgrade
	
### Step 5. Install USB automount
This makes your USB storage easiest to mount at boot and any time you disconnect and connect again.

	sudo apt-get install usbmount

### Step 6. Download our script

Download the script:

	cd /home/pi
	wget https://raw.githubusercontent.com/kalanda/RPi-MediaLooper/master/videoloop.sh

Add permissions to execute:

	chmod +x videoloop.sh
	
### Step 7. Test the script

Put a video or audio file in a USB storage device and connect it to *Raspberry Pi*, then write this at your prompt:

	./videoloop.sh
	
This should play your video in a endless loop. Press CTRL-C anytime to exit.
	
### Step 8. Configure autologin without password
Our system is not necessary connected to a keyboard to work and has not any sensible data, then autologin is not a problem and makes easy to run our script at startup.

Edit `/etc/inittab`

	sudo nano /etc/inittab

Disable the getty program by adding `#` to comment this line:

	#1:2345:respawn:/sbin/getty 115200 tty1

Add login program to inittab adding the following line just below the commented line
	
	1:2345:respawn:/bin/login -f pi tty1 </dev/tty1 >/dev/tty1 2>&1

This will run the login program with *pi* user and without any authentication.

When is done, press CTRL-O and ENTER to save and CTRL-X to exit.

### Step 9. Add script to startup	
To run at startup, edit `/etc/profile` by typing:

	sudo nano /etc/profile
	
Add `/home/pi/videoloop.sh` at the end of file

When is done, press CTRL-O and enter to save and CTRL-X to exit.

Now you can reboot your system to test:

	sudo reboot
	
Script will start automatically when systems reboots.
	
## 	Prevent SD card from getting corrupted

If your system will be placed in a environment where shutdown is done by switching power supply, the SD card can get corrupted easily if shutdown occurs while system is writing data. To prevent this situation is possible to mount all partitions with readonly flag and put logs and pids at RAM memory (erased at shutdown). 

Edit `/etc/fstab` by typing:

	sudo nano /etc/fstab

Put `ro` (readonly) to *defaults* column of all partitions and add last two lines to mount logs an run in RAM. It should look something like the following. 

	proc            /proc           proc    defaults          0       0
	/dev/mmcblk0p1  /boot           vfat    ro                0       2
	/dev/mmcblk0p2  /               ext4    ro                0       1
	none            /var/run  ramfs   size=1M  0 0
	none            /var/log  ramfs   size=1M  0 0
	
When is done, press CTRL-O and ENTER to save and CTRL-X to exit. Then run: 

	sudo partprobe 
	
This alert system to recognize the new partition. Now you can reboot your system to test

	sudo reboot
	
If for some reason you need to make changes to your system, you can remount the read-only partitions with write access:

	sudo mount -o remount,rw /dev/mmcblk0p2


## Inspiration projects

Finding a good solution for showing a single video throught projectors in a infinite loop using *Raspberry Pi* as hardware. I found some interesting projects on Internet but, each one with their pros and cons. I learn a lot testing those but I decided to take the best of all and make my custom project based on my needs.

#### CuriousTechnologist's solution - [link](http://curioustechnologist.com/post/104242571716/rpilooper-v2-b-seamless-video-looper-for)
**PROS:** Real seamless loop, no blanks or gaps between loops. 

**CONS:** Does not support audio. Is based on a custom binary program coded in C. Requires to prepare videos with a specific feature of h264 codec using AviDemux and naming the file with .h264 extension to work.

#### StevenHickson's solution - [link](http://stevenhickson.blogspot.com.es/2014/05/rpi-video-looper-20.html)

**PROS:** Code is available at [GitHub](https://github.com/StevenHickson/RPiVideoLooper). Is based on *omxplayer*, which can play almost any video format. Creates a service daemon to autoboot.

**CONS:** The loop is not seamless, the gap between loops (1 or 2 seconds) depends of the length of video. If you don't use the disk image, the code has some bugs on the installer and the code because uses a standalone version of *omxplayer* instead the version included by default in *Raspbian*. When *omxplayer* plays your videos, uses the `-l` option for loop, but there are some bugs on this feature. If video has not audio, it hangs on second loop. If video is in a mp4 container, 5 seconds at the end of video will lost in each loop ([issue 291](https://github.com/popcornmix/omxplayer/issues/291)). 

#### GeekTips's solution - [link](http://www.geek-tips.com/2014/07/30/infinite-video-loops-on-a-raspberry-pi/)

**PROS:** Just one bash script. Uses the *omxplayer* that comes with *Raspbian* that is IMO, the best option to play any video, but instead of `-l` option for loop (this option has some bugs commented above) the script calls in a infinite while loop to *omxplayer* for launch the video. Catch for CTRL-C to stop the player.

**CONS:** Has not online repository for code. Don't provides a autoboot feature. 

#### Other similar projects

- [https://github.com/kimaernoudt/videolooper](https://github.com/kimaernoudt/videolooper)
- [https://github.com/asalisbury/videolooper](https://github.com/asalisbury/videolooper)
- [http://www.timschwartz.org/raspberry-pi-video-looper/](http://www.timschwartz.org/raspberry-pi-video-looper/)

### Useful links

- [Shrinking disk images on linux](http://softwarebakery.com/shrinking-images-on-linux)
- [How can I prevent my Pi's SD card from getting corrupted](http://raspberrypi.stackexchange.com/questions/7978/how-can-i-prevent-my-pis-sd-card-from-getting-corrupted-so-often?answertab=active#tab-top)
- [Sound does not work with an HDMI monitor](http://elinux.org/R-Pi_Troubleshooting#Sound_does_not_work_with_an_HDMI_monitor)






