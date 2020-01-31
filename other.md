

```
sudo add-apt-repository ppa:ubuntu-raspi2/ppa
sudo apt-get update
sudo apt-get install linux-raspi2 libraspberrypi-bin  libraspberrypi-bin-nonfree -y
sudo chmod 777 /dev/vchiq
sudo apt-get install libjpeg8-dev imagemagick libv4l-dev -y
sudo apt-get install libopencv-core-dev libopencv-dev libraspberrypi-dev -y
sudo apt-get install python3-pip -y
sudo pip3 install picamera
```
### enable raspi-cam
add content in config.txt
```
start_x=1             # essential
gpu_mem=128           # at least, or maybe more if you wish
disable_camera_led=1  # optional, if you don't want the led to glow
```

review
```
raspivid -t 0
```
runt the python file
```
wget https://raw.githubusercontent.com/lbaitemple/ubuntu_server_rpi/master/torch/rpi_camera_surveillance_system.py
python3 rpi_camera_surveillance_system.py
```

#### bluetooth

In /etc/dbus-1/system.d/bluetooth.conf, add
```
<policy user="ubuntu">
  <allow own="org.bluez"/>
  <allow send_destination="org.bluez"/>
  <allow send_interface="org.bluez.GattCharacteristic1"/>
  <allow send_interface="org.bluez.GattDescriptor1"/>
  <allow send_interface="org.freedesktop.DBus.ObjectManager"/>
  <allow send_interface="org.freedesktop.DBus.Properties"/>
</policy>
```
restart the bluetooth
```
sudo systemctl restart dbus
```
