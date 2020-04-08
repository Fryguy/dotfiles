#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
	IS_MAC=true
else
	USERPROFILE="/mnt/c/Users/Fryguy"
fi

function link_file() {
	file="$1"
	target="$2"
	copy="$3"

	link_dir=$(dirname "$target")
	[ ! -d "$link_dir" ] && echo "Creating $link_dir" && mkdir -p "$link_dir"

	if [ "$copy" == "true" ]; then
		echo "Copying $file -> $target"
		rm -f "$target"
		cp "$file" "$target"
	else
		echo "Linking $target -> $file"
		ln -snf "$file" "$target"
	fi
}

for target in \
	.bundler.d/Gemfile.global.rb \
	.gemrc \
	.gitattributes \
	.gitconfig \
	.gitignore_global \
	.gnupg/gpg-agent.conf \
	.gnupg/gpg.conf \
	.irbrc \
	.profile \
	.pryrc \
	.ruby_tools.rb \
	.vim/colors/twilight-fryguy.vim \
	.vimrc \
	bin
do
	link_file "$DIR/$target" "$HOME/$target"
done

if [ "$IS_MAC" == "true" ]; then
	target="Library/KeyBindings/DefaultKeyBinding.dict"
	link_file "$DIR/$target" "$HOME/$target"

	link_file "$DIR/Sublime Text 3/Packages/User/Twilight (Fryguy).tmTheme" "$HOME/Library/Preferences/bat/themes/Twilight (Fryguy).tmTheme"
fi

IFS=$'\n' files=($(ls "Sublime Text 3/Packages/User"))
for target in ${files[@]}; do
	if [ "$IS_MAC" == "true" ]; then
		copy=false
		target_dir="$HOME/Library/Application Support"
	else
		copy=true
		target_dir="$USERPROFILE/AppData/Roaming"
	fi
	link_file "$DIR/Sublime Text 3/Packages/User/$target" "$target_dir/Sublime Text 3/Packages/User/$target" "$copy"
done
