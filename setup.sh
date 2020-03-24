#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for target in \
	.gemrc \
	.gitattributes \
	.gitconfig \
	.gitignore_global \
	.irbrc \
	.profile \
	.pryrc \
	.ruby_tools.rb \
	bin \
	"Library/KeyBindings/DefaultKeyBinding.dict"
do
	link_dir="$(dirname ~/"$target")"
	[ ! -d "$link_dir" ] && echo "Creating $link_dir" && mkdir -p "$link_dir"

	echo "Linking $target"
	ln -sfh "$DIR/$target" ~/"$target"
done

IFS=$'\n' files=($(ls "Sublime Text 3/Packages/User"))
for target in ${files[@]}; do
	echo "Linking $target"
	ln -sfh "$DIR/Sublime Text 3/Packages/User/$target" ~/"Library/Application Support/Sublime Text 3/Packages/User/$target"
done

mkdir -p ~/Library/Preferences/bat/themes
ln -sfh "$DIR/Library/Application Support/Sublime Text 3/Packages/User/Twilight (Fryguy).tmTheme" ~/"Library/Preferences/bat/themes/Twilight (Fryguy).tmTheme"
