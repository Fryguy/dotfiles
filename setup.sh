#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for target in \
	.gemrc \
	.gitconfig \
	.gitignore_global \
	.irbrc \
	.profile \
	.pryrc \
	.ruby_tools.rb \
	bin \
	Documents/dotfiles \
	"Library/Application Support/Sublime Text 3/Packages/ManageIQ Log" \
	"Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings" \
	"Library/Application Support/Sublime Text 3/Packages/User/Twilight (Fryguy).tmTheme"
do
  echo "Linking $target"
  ln -sfh "$DIR/$target" ~/"$target"
done

mkdir -p ~/Library/Preferences/bat/themes
ln -sfh "$DIR/Library/Application Support/Sublime Text 3/Packages/User/Twilight (Fryguy).tmTheme" "~/Library/Preferences/bat/themes/Twilight (Fryguy).tmTheme"
