# Perok's dotfiles


Installation guide
------------------

Uses: https://github.com/anishathalye/dotbot/

Clone and ./install linux or mac

    $ sudo ln -s ~/dotfiles/bin/sane-rm /usr/local/bin/rm

# TODO migrate all to stow
- stow-shell
  dir colors, inputrc
- TMUX 3.1 will support XDG spec. Move tmux config file to correct location


## Firefox

- Setup userChrome
  - Find profile name
  - `ln -s ~/.dotfiles/firefox/userChrome.css ~/.mozilla/firefox/852x0ns6.default-release/chrome/userChrome.css`
- Ensure that all new tabs are opened in same window - In `about:config`
  - `browser.link.open_newwindow = 3`
  - `browser.link.open_newwindow.restriction = 0`

## AppImage

Install [Appimaged](https://github.com/AppImage/appimaged)

Todo
----

- Add .local/bin here?
- Skift til stow?
- then change to Hasklig Medium
- enhancd, powerlevel9k, ripgrep, fzy?
* http://zshwiki.org/home/zle/vi-mode
* with https://github.com/zsh-users/zsh/blob/master/Functions/Zle/surround
* http://vimrcfu.com/snippet/77
* http://vimrcfu.com/snippet/182

