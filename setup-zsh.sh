#!/bin/bash

set -e

SOURCE_REPO=${SOURCE_REPO:-Fryguy/prezto}

git clone --recursive git@github.com:SOURCE_REPO ~/.zprezto
cd ~/.zprezto
git remote add upstream git@github.com:sorin-ionescu/prezto
git checkout changes
git submodule update --init --recursive
setopt EXTENDED_GLOB
for rcfile in ~/.zprezto/runcoms/^README.md(.N); do
	ln -s "$rcfile" "~/.${rcfile:t}"
done
