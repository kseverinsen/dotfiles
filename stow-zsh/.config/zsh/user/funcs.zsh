function start_tmux() {
  if type tmux &> /dev/null; then
    #if not inside a tmux session, and if no session is started, start a new session
    if [[ $HOST == "Great-Pooto" && -z "$TMUX" && -z $TERMINAL_CONTEXT ]]; then
      (tmux -2 attach || tmux -2 new-session)
    fi
  fi
}

# ftpane - switch pane (@george-b)
ftpane() {
  local panes current_window current_pane target target_window target_pane
  panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_pane=$(tmux display-message -p '#I:#P')
  current_window=$(tmux display-message -p '#I')

  # TODO fzf-tmux
  target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

  target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
  target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

  if [[ $current_window -eq $target_window ]]; then
    tmux select-pane -t ${target_window}.${target_pane}
  else
    tmux select-pane -t ${target_window}.${target_pane} &&
      tmux select-window -t $target_window
  fi
}


function docker_ip() {
  local container_id=$(docker ps | grep $1 | awk '{print $ 1}' | tail -n 1)

  if [ $container_id ]; then
    docker inspect $container_id \
      | grep -w "IPAddress" \
      | awk '{ print $2 }' \
      | tail -n 1
  else
    echo 'Unknown container' $1 1>&2
    return 1
  fi
}

function murderAllPort() {
  lsof -i:$1 | tail -n +2 | awk '{ print $2 }' | xargs -L1 kill -9
}

# ###############
# FZF Functions
# ###############
# Borrowed from: https://github.com/ctaylo21/jarvis/blob/master/zsh/zshrc.symlink
#

# fh [FUZZY PATTERN] - Search in command history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fbr [FUZZY PATTERN] - Checkout specified branch
# Include remote branches, sorted by most recent commit and limited to 30
fgb() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# tm [SESSION_NAME | FUZZY PATTERN] - create new tmux session, or switch to existing one.
# Running `tm` will let you fuzzy-find a session mame
# Passing an argument to `ftm` will switch to that session if it exists or create it otherwise
ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

# tmk [SESSION_NAME | FUZZY PATTERN] - delete tmux session
# Running `tm` will let you fuzzy-find a session mame to delete
# Passing an argument to `ftm` will delete that session if it exists
ftmk() {
  if [ $1 ]; then
    tmux kill-session -t "$1"; return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux kill-session -t "$session" || echo "No session found to delete."
}

fzfgitcommits() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --header "Press CTRL-S to toggle sort" \
      --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                 xargs -I % sh -c 'git show --color=always % | head -$LINES'" \
      --bind "enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
              xargs -I % sh -c 'vim fugitive://\$(git rev-parse --show-toplevel)/.git//% < /dev/tty'"
}


# SSH bookmark creator
# Source http://www.splitbrain.org/blog/2012-09/06-ssh_alias_script
sbm() {
    if [ $# -lt 2 ]; then
        echo "Usage: sbm <short> [<user>@]<hostname> [-p <port>]" >&2
        return 1
    fi

    short=$1
    arg=$2

    if $(echo "$arg" | grep '@' >/dev/null); then
        user=$(echo "$arg"|sed -e 's/@.*$//')
    fi

    host=$(echo "$arg"|sed -e 's/^.*@//')

    if [ "$3" == "-p" ]; then
        port=$4
    fi

    if $(grep -i "host $short" "$HOME/.ssh/config" > /dev/null); then
        echo "Alias '$short' already exists" >&2
        return 1
    fi

    if [ -z "$host" ]; then
        echo "No hostname found" >&2
        return 1
    fi

    echo >> "$HOME/.ssh/config"
    echo "host $short" >> "$HOME/.ssh/config"
    echo "  hostname $host" >> "$HOME/.ssh/config"
    [ ! -z "$user" ] && echo "  user     $user" >> "$HOME/.ssh/config"
    [ ! -z "$port" ] && echo "  port     $port" >> "$HOME/.ssh/config"

    echo "added alias '$short' for $host"
}
