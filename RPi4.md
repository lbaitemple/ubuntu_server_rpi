# Ubuntu Server 18.04.3 (Bionic) ARM image for Raspberry Pi 4

### Download image
https://github.com/TheRemote/Ubuntu-Server-raspi4-unofficial/releases

64-bit (download server version without GUI)

https://github.com/TheRemote/Ubuntu-Server-raspi4-unofficial/releases/download/v26/ubuntu-18.04.3-preinstalled-server-arm64+raspi4.img.xz

## Instructions
### step 1: Upgrade System 
Burn the image to SD card with dd/etcher/DiskWritter or your favorite tool.

Username: **ubuntu**  
Password: **ubuntu**

18.04.3 will need you to change default password. 

Check your system architecture, you can use
```
 uname -m
```

SSH is enabled by default, so you can login directly after first boot. However, it is recommended to connect to ethernet and use a HDMI screen to upgrade the system first. 

```
sudo apt-get update
sudo apt-get upgrade -y
```

If any lock files presented, please sudo remove them and 
```
sudo rm /var/lib/dpkg/lock*
sudo dpkg --configure -a
sudo apt-get upgrade -y
```
#### upgrade may take up to 30 mins. When a selection is requested, please use TAB key to select yes option.

### step 2: Setup I2C
After the system is upgraded in step 1, you can ssh to the raspberry pi in step 2 when your computer and your pi are on the same LAN. 


After login, you can use the following commands by copying and pasting into the ssh shell
When everything is completed, you will need to do the following commands to enable I2C
```
sudo apt-get install python-pip python-pil  i2c-tools mosquitto-clients -y
sudo pip install Adafruit_SSD1306 RPi.GPIO
```

To enable I2c permission
```
sudo chgrp i2c /dev/i2c-1
sudo chmod 666 /dev/i2c-1
sudo usermod -G i2c $USER
```

If everything wents through successfully, please go to step 3.

If you do not see the file /dev/i2c-1. Please add i2c in configure file
```
sudo nano /boot/firmware/config.txt
```

Make sure you have (I2C, SPI and UART)
```
dtparam=i2c_arm=on
dtparam=spi=on
enable_uart=1
```
add the following line to the file /etc/modules.
```
i2c-dev
```
To enable I2c permission
```
sudo chgrp i2c /dev/i2c-1
sudo chmod 666 /dev/i2c-1
sudo usermod -G i2c $USER
```


### step 3: Setup everything for IP 

* To get wireless connection working on boot you must edit **/etc/netplan/01-rpi-3-network.yaml** present in *cloudimg-rootfs* partition in your sdcard and add your SSID and PASSWORD using a HDMI screen monitor.
Open file
For 18.04.2
```
sudo nano /etc/netplan/01-rpi-3-network.yaml
```
For 18.04.3
```
sudo nano /etc/netplan/50-cloud-init.yaml
```


Please include the following content and make sure you generate your password 32-character hash (see line include command 

 ![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `echo -n [password] | iconv -t UTF-16LE | openssl md4`
 
```
network:
        version: 2
        renderer: networkd
        ethernets:
                eth0:
                  optional: true
                  dhcp4: true
        wifis:
             wlan0:
                optional: true
                dhcp4: true
                access-points:
                        "HOMEWIFIACCESSPOINT":
                                password: "password123"
                        tusecurewireless:
                                auth:
                                   key-management: eap
                                   password: hash:[insert hash value]
                                   method: peap
                                   identity: lbai

```
In the above configuration file, we have two wifi networks. You can change wifi access point ssid and password. For the tusecurewireless network, you will need to replace your tuaccess ID in "idenitity" field (For example, replace lbai as tuxxxx) and insert a 32-character hash based on the password using "echo -n ...." command

After you save the configuration file, you can apply netplan
```
sudo netplan --debug generate
sudo netplan try

```
You may have to reboot to get IP address up. Now you can setup MQTT client in startup script file
```
cd ~
git clone https://github.com/lbaitemple/ubuntu_server_rpi
cp ubuntu_server_rpi/newtest2.sh ~/test2.sh
cp ubuntu_server_rpi/stats.py ~/
chmod +x test2.sh
```

You can open test2.sh and modify cloud MQTT setting. If you do not have a cloud MQTT account, please go to https://www.cloudmqtt.com/ to setup one free account. 
```
nano ~/test2.sh
```

You will need to ensure a startup service to enable network
```
sudo systemctl is-enabled systemd-networkd-wait-online.service
sudo systemctl enable systemd-networkd-wait-online.service
```
Now, you will need to create a startup service
```
sudo cp ~/ubuntu_server_rpi/ipaddress.service /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable  ipaddress
sudo systemctl start  ipaddress
```
You can setup a MQTT subscriber to wait the ip address is published to the MQTT topic. Also, you should be able to see the IP address on OLED screen if you connect your I2C OLED screen (https://esphome.io/components/display/ssd1306.html) to your Pi.

#### optional step 3a: display ip address without login (with a monitor)
open a file 

```
sudo nano /etc/issue
```
add two lines in the bottom of the file
```
eth0: \4{eth0}
wlan0: \4{wlan0}
```

### step 4: Increase swap memory
When you compile files, you may need a larger swap memory becasue raspberry pi 3 has only 1GB memory.

Enter the command as follows to setup 4G swap space
```
sudo dd if=/dev/zero of=/swap1 bs=1M count=4096
sudo mkswap /swap1
sudo swapon /swap1
```
take around 5 mins to create 4G swap space. If you need to include the swap space during every bootup, you can open a file
```
sudo nano /etc/fstab
```
Add a line to the bottom of the file
```
/swap1 swap swap
```
close and save the file. You can check if there is a swap memory by typing
```
free -th
```
### step 5: Install ROS
```
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt-get update
sudo apt-get install ros-melodic-desktop -y
sudo rosdep init
rosdep update
echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
```

### step 6: Setup USB-C OTG
#### open configuration file
```
sudo nano /boot/firmware/config.txt
```
add a line to the end of the file
```
dtoverlay=dwc2
```

#### open cmdline file
```
sudo nano /boot/firmware/cmdline.txt
```
add below to the end of the first line
```
modules-load=dwc2 
```
#### open moddule file
```
sudo nano /etc/modules
```
add  a line to the end of the file
```
libcomposite 
```

#### open dhcpcd.conf file
```
sudo nano  /etc/dhcpcd.conf
```
add  a line to the end of the file
```
denyinterfaces usb0 
```

###### Install dnsmasq
```
sudo apt-get install dnsmasq -y
sudo nano /etc/dnsmasq.d/usb
```
Add the following content
```
interface=usb0
dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h
dhcp-option=3
leasefile-ro
```

###### Install ifdownup
```
sudo apt-get install ifupdown -y
sudo nano /etc/network/interfaces
```
Add the following content
```
auto usb0
allow-hotplug usb0
iface usb0 inet static
  address 10.55.0.1
  netmask 255.255.255.248
```

#### create a startup file
```
sudo nano /root/usb.sh
```
Add the following content
```
#!/bin/bash
cd /sys/kernel/config/usb_gadget/
mkdir -p pi4
cd pi4
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2
echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
mkdir -p strings/0x409
echo "fedcba9876543211" > strings/0x409/serialnumber
echo "Ben Hardill" > strings/0x409/manufacturer
echo "PI4 USB Device" > strings/0x409/product
mkdir -p configs/c.1/strings/0x409
echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower
# Add functions here
# see gadget configurations below
# End functions
mkdir -p functions/ecm.usb0
HOST="00:dc:c8:f7:75:14" # "HostPC"
SELF="00:dd:dc:eb:6d:a1" # "BadUSB"
echo $HOST > functions/ecm.usb0/host_addr
echo $SELF > functions/ecm.usb0/dev_addr
ln -s functions/ecm.usb0 configs/c.1/
udevadm settle -t 5 || :
ls /sys/class/udc > UDC
ifup usb0
service dnsmasq restart
```

#### create rc.local file
```
sudo nano /etc/rc.local
```
Add the following content
```
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
/root/usb.sh

exit 0
```

#### make /root/usb.sh executable
```
sudo chmod +x /etc/rc.local
sudo chmod +x /root/usb.sh
```
### step 7: Install ROS2  [make sure you have a 32-bit image installed. Not completely tested it]
https://index.ros.org/doc/ros2/Installation/Dashing/Linux-Install-Debians/#install-ros-2-packages


```
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
```

```
sudo apt update && sudo apt install curl gnupg2 lsb-release
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo sh -c 'echo "deb [arch=armhf] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
```

```
sudo apt update
sudo apt install ros-dashing-desktop -y
sudo apt install python3-argcomplete
```

Build the code in the workspace
```
source /opt/ros/dashing/setup.bash
echo "source /opt/ros/dashing/setup.bash" >> ~/.bashrc
````


Try some examples
```
. ~/ros2_dashing/install/local_setup.bash
ros2 run demo_nodes_cpp talker
```
In another terminal source the setup file and then run a listener:
```
. ~/ros2_dashing/install/local_setup.bash
ros2 run demo_nodes_py listener
```
#### step 8: Update firmware
```
sudo curl -L --output /usr/bin/rpi-update https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update && sudo chmod +x /usr/bin/rpi-update
sudo rpi-update
```
#### step 9: GPIO run as non-root (/dev/mem no access)
```
sudo groupadd gpio
sudo usermod -a -G gpio ubuntu
sudo grep gpio /etc/group
sudo chown root.gpio /dev/gpiomem
sudo chmod g+rw /dev/gpiomem
echo "sudo chown root.gpio /dev/gpiomem" >> ~/.bashrc
echo "sudo chmod g+rw /dev/gpiomem" >> ~/.bashrc
```
GPIO python testcode
```
import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM) # Broadcom pin-numbering scheme
GPIO.setup(18, GPIO.OUT)

print "work.... for 5 sec ...."
time.sleep(5)
GPIO.cleanup()

```
#### step 10: Install OpenCV
```
sudo apt-get install python3-opencv python3-pillow -y
```

#### step 11: Install Pytorch
Verify your python version and arch  
```
python3 --version
```
If you have 3.6 and arch=32-bit
```
wget https://github.com/lbaitemple/ubuntu_server_rpi/raw/master/torch/torch-1.4.0a0%2Bbc91e19-cp36-cp36m-linux_armv7l.whl
sudo pip3 install torch-1.4.0a0%2Bbc91e19-cp36-cp36m-linux_armv7l.whl
wget https://github.com/lbaitemple/ubuntu_server_rpi/raw/master/torch/torchvision-0.5.0a0%2B95131de-cp36-cp36m-linux_armv7l.whl
sudo pip3 install torchvision-0.5.0a0%2B95131de-cp36-cp36m-linux_armv7l.whl
```
If you have other version, please go to torch folder to find a correct version torch and torchvision wheel to install.
If you want to install from source, please follow the procedures below. However, it takes really long time (2 days for me in a raspberry pi 3B+).

```
sudo apt install libopenblas-dev libblas-dev m4 cmake cython python3-dev python3-yaml python3-setuptools -y
mkdir pytorch_install && cd pytorch_install
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
```

#### step 12: create jupyter

```
sudo apt-get update
sudo apt-get install python3-matplotlib python3-scipy python3-pip -y
sudo pip3 install jupyter
sudo apt-get clean
sudo update-alternatives --config x-www-browser
sudo reboot
```
Create an alias in .bashrc
```
nano .bashrc
```
Add
```
alias runserver='jupyter notebook  --port 8888 --ip  '
```
Save the file and you can run
```
source ~/.bashrc
runserver ip_address
```



###### setup environment variables
```
export NO_CUDA=1
export NO_DISTRIBUTED=1
export NO_MKLDNN=1 
export NO_NNPACK=1
export NO_QNNPACK=1
```

AFter that, you can start building (source, wheel)
```
python3 setup.py build
python3 setup.py sdist bdist_wheel
sudo -E python3 setup.py install
```


####
```
sudo dpkg --add-architecture amd64
```
* Filesystem will be expanded to fit your SD Card size on first boot.
