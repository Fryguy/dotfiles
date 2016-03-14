#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for target in \
	.gemrc \
	.gitconfig \
	.git_hooks \
	.gitignore_global \
	.irbrc \
	.profile \
	.pryrc \
	bin \
	Documents/dotfiles \
	"Library/Application Support/Sublime Text 3/Packages/ManageIQ Log" \
	"Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings" \
	"Library/Application Support/Sublime Text 3/Packages/User/Twilight (Fryguy).tmTheme"
do
  echo "Linking $target"
  ln -sfh "$DIR/$target" ~/"$target"
done
