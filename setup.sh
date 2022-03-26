#!bash

sudo apt update
sudo apt upgrade -y
sudo apt install python3 python3-pip
sudo apt install i2c-tools git
sudo apt install mosquitto mosquitto-clients
sudo pip3 install smbus
pip3 install paho-mqtt

sudo reboot -h

