#!/bin/bash

SOURCE_REPO=${SOURCE_REPO:-Fryguy/dotfiles}

mkdir ~/projects
git clone git@github.com:$SOURCE_REPO ~/projects/dotfiles
cd ~/projects/dotfiles
./setup.sh

