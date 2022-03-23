#!bash

wget https://github.com/blues/note-go/releases/download/v1.4.9/notehubcli_linux_arm.tar.gz
wget https://github.com/blues/note-go/releases/download/v1.4.9/notecardcli_linux_arm.tar.gz
tar xzf notecardcli_linux_arm.tar.gz
PATH=$PATH:/home/pi
notecard -interface i2c
pip3 install note-python python-periphery
`
