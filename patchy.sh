#!/bin/bash

cd ~
wget https://github.com/cdelashmutt-pivotal/pcf-patch/archive/master.zip
unzip master.zip
cd pcf-patch-master
sudo ./apply-patch.sh
