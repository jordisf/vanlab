#!/bin/bash
set -e
set -u

sudo systemctl stop kiosk.service || true
