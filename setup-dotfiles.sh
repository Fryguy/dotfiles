#!/bin/bash

set -e

SOURCE_REPO=${SOURCE_REPO:-Fryguy/dotfiles}
DIR=$HOME/projects/dotfiles

if [ ! -d $DIR ]; then
  mkdir -p $(dirname $DIR)
  git clone git@github.com:$SOURCE_REPO $DIR
fi
cd $DIR
./setup.sh

