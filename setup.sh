#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for OBJECT in bin .gemrc .gitconfig .gitignore_global .irbrc .profile .pryrc; do
  echo "Linking $OBJECT"
  ln -sf $DIR/$OBJECT ~/$OBJECT
done
