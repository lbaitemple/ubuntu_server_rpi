

```
sudo add-apt-repository ppa:ubuntu-raspi2/ppa
sudo apt-get update
sudo apt-get install linux-raspi2 libraspberrypi-bin  libraspberrypi-bin-nonfree -y
sudo chmod 777 /dev/vchiq
sudo apt-get install libjpeg8-dev imagemagick libv4l-dev -y
sudo apt-get install libopencv-core-dev libopencv-dev libraspberrypi-dev -y
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
