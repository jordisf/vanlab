#!/bin/bash
set -e
set -u

systemctl stop kiosk.service || true
