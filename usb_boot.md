Install Ubuntu-mate on a usb flash drive.

Get the SD card that you are going to use for the boot section and format it FAT32 

Rename the card "system_boot"

copy all of the files from the usb drive to root of sd card 

Edit the cmdline.txt file On the SD card, change /dev/mmcblkp2 to /dev/sda2 and save the file.
```
1.place both usb and sdcard in the pi and boot
2.go thru the setup and let the installation take place
3.After installtion is complete and your at the home screen open the terminal
4. sudo fdisk /dev/sda 
5.press p than enter, take note of what block sda2 starts with, mine was 133120
6.press d than enter, 
7.press 2  than enter, this will delete the second partition
8.press n than enter, this will create the new partition process 
9.press p for primary partiton, than enter
10.press 2, than enter
11.now you will see the first sector,now type in the block number you took note of earlier mine was 133120 and hit enter
12.now you will the end sector, here just choose the default by pressing enter
13.now type w than enter, this will write the partiton
14.you will see a message about the kernel yaddah yaddah, just ignore this. Now reboot the system.
15.After the system reboots, open the terminal and type sudo resize2fs /dev/sda2 and press enter. 
16.After the resizing process run df -h to make sure it has resized.
17. from the terminal edit the file sudo nano /etc/fstab
18. edit the line that has /dev/mmcblk0p2 to /dev/sda2 and save the file
```
Thats it all done!﻿
