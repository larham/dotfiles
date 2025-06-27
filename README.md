# Setup macos workstation

Configurations managed by [chezmoi](https://github.com/twpayne/chezmoi). Using `chezmoi cd` will put you into the actual .git directory used by chezmoi as a workspace, distributed by `chezmoi apply`.

## Bootstrap a macos machine using chezmoi + dotfiles repo

1. Install git, curl with system package manager: type `git` on command line and it should prompt you to install XCode tools, or:
2. `xcode-select --install`
3. [Install brew](https://brew.sh)
4. `brew doctor`
5. `brew install chezmoi`
6. `chezmoi init https://larham@github.com/larham/dotfiles.git`
7. `chezmoi apply` # will ask for sudo password, can take a long time to install apps. If it doesn't install apps, use `brew bundle --file=dot_brewfile/Brewfile.local` where that Brewfile.local is under parent directory `~/.local/share/chezmoi` (where all the chezmoi files are stored)
8. Reboot
9. Download [spooninstaller](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip)
10. `mkdir -p ~/.hammerspoon/Spoons`
11. `cd  ~/.hammerspoon/Spoons && unzip ~/Downloads/SpoonInstall.spoon.zip` or, if macos auto-unzipped, `cp -R ~/Downloads/SpoonInstall.spoon ~/.hammerspoon/Spoons/`
12. Start hammerspoon (for windowing)
13. Start Maccy (for clipboard), and open app prefs to enable checkboxes: "Launch at login" and "Paste automatically". Both of these preferences require a manual manipulation of System preferences:
    1.  Login -> Open at Login
    2.  Security->Accessibility (Allow the applications below to control your computer)
14. Some system prefs have to be done manually:
    1.  Trackpad: click to touch
15. Update [~/.oh-my-zsh](https://stackoverflow.com/questions/33486633/upgrading-oh-my-zsh-gives-me-not-a-git-repository-error):
```bash
cd ~/.oh-my-zsh
git init
git remote add origin https://github.com/ohmyzsh/ohmyzsh.git
git fetch
git reset --hard origin/master
```

## jettison (todo: incorporate default read/write to automate this)
Configure to eject on lid close & upon keystroke: cmd-alt-ctrl-delete

## rclone external backups
`sudo chmod a+w /var/log`
See service plist 'larry.rclone.sync.plist' in folder &lt;initials&gt;, which calls script found in same folder, activate with:
`launchctl load -w ~/<initials>/larry.rclone.sync.plist`

## timemachineeditor
Configure to backup daily at night when powered; see ~/&lt;initials&gt;/timemachine-scripting/

## Brew: compare currently installed apps with the install script in order to update install script

To update the local script for installing apps:
```
cd /tmp
brew bundle dump
# now visual compare, with older, persisted copy on left
meld  $HOME/.local/share/chezmoi/dot_brewfile/Brewfile.local  ./Brewfile
# then the usual chezmoi followup: `chezmoi cd && git add . && git commit ...`
```
