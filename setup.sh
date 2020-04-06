#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
	IS_MAC=true
fi

function link_file() {
	file="$1"
	target="$2"

	link_dir=$(dirname "$target")
	[ ! -d "$link_dir" ] && echo "Creating $link_dir" && mkdir -p "$link_dir"

	echo "Linking $target -> $file"
	ln -sf "$file" "$target"
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
	bin
do
	link_file "$DIR/$target" ~/"$target"
done

if [ "$IS_MAC" == "true" ]; then
	target="Library/KeyBindings/DefaultKeyBinding.dict"
	link_file "$DIR/$target" ~/"$target"

	link_file "$DIR/Sublime Text 3/Packages/User/Twilight (Fryguy).tmTheme" ~/"Library/Preferences/bat/themes/Twilight (Fryguy).tmTheme"
fi

IFS=$'\n' files=($(ls "Sublime Text 3/Packages/User"))
for target in ${files[@]}; do
	if [ "$IS_MAC" == "true" ]; then
		target_dir=~/"Library/Application Support"
	else
		target_dir="/mnt/c/Users/Fryguy/AppData/Roaming"
	fi
	link_file "$DIR/Sublime Text 3/Packages/User/$target" "$target_dir/Sublime Text 3/Packages/User/$target"
done
