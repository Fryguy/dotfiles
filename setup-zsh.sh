#!/bin/zsh

set -e

SOURCE_REPO=${SOURCE_REPO:-Fryguy/prezto}
DIR=$HOME/.zprezto

if [ ! -d $DIR ]; then
	git clone --recursive git@github.com:$SOURCE_REPO $DIR
	pushd $DIR
		git remote add upstream git@github.com:sorin-ionescu/prezto
		git checkout changes
		git submodule update --init --recursive
	popd
fi

cd $DIR
setopt EXTENDED_GLOB
for rcfile in $DIR/runcoms/^README.md(.N); do
	echo "Linking $rcfile to $HOME/.${rcfile:t}"
	ln -F -s "$rcfile" "$HOME/.${rcfile:t}"
done
