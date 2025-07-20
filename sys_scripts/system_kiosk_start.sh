#!/bin/bash
set -e
set -u

systemctl start kiosk.service || true
