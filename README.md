# Setup macos workstation

Configurations managed by [chezmoi](https://github.com/twpayne/chezmoi).

## Bootstrap a macos machine using chezmoi + dotfiles repo

1. Install git, curl with system package manager: type `git` on command line and it should prompt you to install XCode tools, or:
2. `xcode-select --install`
3. [Install brew](https://docs.brew.sh/Installation)
4. `brew doctor`
5. `brew install chezmoi`
6. `chezmoi init https://larham@bitbucket.org/larham/dotfiles.git`
7. `chezmoi apply` # will ask for sudo password, can take a long time to install apps. If it doesn't install apps, use `brew bundle --no-lock --file=dot_brewfile/Brewfile.local` where that Brewfile.local is under parent directory `~/.local/share/chezmoi` (where all the chezmoi files are stored)
8. Reboot
9. Start hammerspoon (for windowing), flycut (for clipboard), google drive; use the prefs of each of these apps to set each to launch at startup
10. Download [spooninstaller](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip)
11. `cd  ~/.hammerspoon/Spoons && unzip ~/Downloads/SpoonInstall.spoon.zip`
11. Update [~.oh-my-zsh](https://stackoverflow.com/questions/33486633/upgrading-oh-my-zsh-gives-me-not-a-git-repository-error)

## Brew: compare currently installed apps with the install script in order to update install script

To update the local script for installing apps:
```
cd /tmp
brew bundle dump
# now visual compare, with older, persisted copy on left
meld  $HOME/.local/share/chezmoi/dot_brewfile/Brewfile.local  ./Brewfile
# then the usual chezmoi followup: `chezmoi cd && git add . && git commit ...`
```

## rclone external backups
`sudo chmod a+w /var/log`
See service plist 'larry.rclone.sync.plist' in folder 'lah', which calls script found in same folder, activate with:
`launchctl load -w ~/lah/larry.rclone.sync.plist`

## jettison
Configure to eject on lid close & upon keystroke: cmd-alt-ctrl-delete

## timemachineeditor
Configure to backup daily at night when powered; see ~lah/timemachine-scripting/

## local mac settings
`~/.local/share/chezmoi/macos/macos.sh` # will ask for sudo password
