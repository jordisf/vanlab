#!/bin/bash
set -e
set -u

cp ./artifacts/StartKiosk.sh ~/Desktop/StartKiosk.sh
chmod +x ~/Desktop/StartKiosk.sh

cp ./artifacts/ScreenManager.py /usr/local/sbin/ScreenManager.py
chmod +x /usr/local/sbin/ScreenManager.py
