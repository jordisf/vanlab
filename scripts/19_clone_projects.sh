#!/bin/bash
set -e
set -u

git config --global user.email "jordisf@gmail.com"
git config --global user.name "Jordi Sans"

git remote set-url origin git@github.com:jordisf/vanlab.git

echo "--> Inicializando y actualizando submódulos de Git..."
git submodule update --init --recursive
echo "--> Submódulos actualizados. Tu proyecto web debería estar en projects/my_website/."