#!/bin/bash
set -e
set -u

cp ./artifacts/StartKiosk.sh ~/Desktop/StartKiosk.sh
chmod +x ~/Desktop/StartKiosk.sh

sudo cp ./artifacts/ScreenManager.py /usr/local/sbin/ScreenManager.py
sudo chmod +x /usr/local/sbin/ScreenManager.py
