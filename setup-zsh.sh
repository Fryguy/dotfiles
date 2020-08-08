#!/bin/bash

SOURCE_REPO=${SOURCE_REPO:-Fryguy/prezto}

git clone --recursive git@github.com:SOURCE_REPO "${ZDOTDIR:-$HOME}/.zprezto"
cd "${ZDOTDIR:-$HOME}/.zprezto"
git remote add upstream git@github.com:sorin-ionescu/prezto
git checkout changes
git submodule update --init --recursive
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
	ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
