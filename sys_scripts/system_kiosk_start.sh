#!/bin/bash
set -e
set -u

sudo systemctl start kiosk.service || true
