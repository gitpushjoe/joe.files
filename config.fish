set -x LC_ALL "C"  
  
# BEGIN ANSIBLE MANAGED BLOCK  
set -x LC_ALL C.UTF-8  
set -x LANG C.UTF-8  
# END ANSIBLE MANAGED BLOCK  
  
# BEGIN ULIMITS BLOCK  
ulimit -v unlimited  
ulimit -n 64000  
ulimit -u 64000  
ulimit -l 256000  
# END ULIMITS BLOCK  
  
# BEGIN ULIMITS BLOCK WT  
ulimit -c unlimited  
# END ULIMITS BLOCK WT  
  
set -x MANPAGER "nvim +Man!"

# Echo and run a command
function echorun 
    echo $argv
    eval $argv
end

# Activate python3-venv
function srcme  
    pushd ~/mongo > /dev/null  
    source python3-venv/bin/activate.fish
    popd > /dev/null  
end  
  
# Activate alternative venv
function srcme2
    pushd ~/mongo > /dev/null  
    source venv/bin/activate.fish
    popd > /dev/null  
end  
  
# Make directory and cd into it.
function cmkdir  
    mkdir -p $argv[1]   
    cd $argv[1]  
end  
  
set -x NVM_DIR "$HOME/.nvm"  
bash -c '[ -s "$NVM_DIR/nvm.sh" ] && source $NVM_DIR/nvm.sh  '
bash -c '[ -s "$NVM_DIR/bash_completion" ] && source $NVM_DIR/bash_completion  '
  
function shush  
    $argv 2>/dev/null  
end  
  
function quiet  
    $argv 1>/dev/null 2>/dev/null  
end  
  
# Setup zoxide for Fish shell  
status --is-interactive; and zoxide init fish | source  
  
# Source fzf configuration (Fish does not need explicit sourcing like Bash).  
if test -f ~/.fzf.fish  
    source ~/.fzf.fish  
end  
  
# function tmuxthing  
#     tmux set-option -t code status-style default   # Transparent background  
#     tmux set-option -t code status-bg default      # Black text  
#     tmux set-option -t code status-fg colour105      # Black text  
# end  
#   
# if not set -q TMUX  
#     # Start or attach to "notes" session  
#     tmux has-session -t notes 2>/dev/null || tmux new-session -d -s notes  
#     tmux set-option -t notes status-style default   # Transparent background  
#     tmux set-option -t notes status-fg grey  
#   
#     # Start or attach to "code" session  
#     tmux has-session -t code 2>/dev/null || tmux new-session -d -s code  
#     tmux set-option -t notes status-style default   # Transparent background  
#     tmux set-option -t code status-fg colour91      # Black text  
#   
#     tmuxthing  
#   
#     # Attach to the default session  
#     tmux attach-session -t notes  
# end  
  
# Open the last opened file in Neovim
function nv
    if test (count $argv) -eq 0  
        /usr/local/bin/nvim -c "lua open_recent()"  
        # TODO: add link
    else  
        /usr/local/bin/nvim $argv  
    end  
end  
  
# Run command and open in Nvim
function n  
    $argv | /usr/local/bin/nvim  
end  
  
# Open blank Neovim
function ne  
    /usr/local/bin/nvim
end  
  
# Open current directory in Neovim
function nd
    /usr/local/bin/nvim .
end  
  
# Source Fish config
function so  
    echo "source ~/.config/fish/config.fish"  
    source ~/.config/fish/config.fish  
end  
  
# Run command and open in less
function l
    $argv | less  
end  

# Get the current git branch  
function gitbranch
    git rev-parse --abbrev-ref HEAD | head -1
end

# Push to Github, with checks for TODO/mydebug
function gitpush  
    # Get the upstream branch
    set upstream (git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)

    # Get the current branch
    set branch (gitbranch)  

    # If I haven't pushed yet, then set the upstream branch to origin/$branch
    if test -z "$upstream"
        echorun "git push --set-upstream origin $branch"  
        return
    end

    # TODO: avoid double-generating the diff

    # Print the diff
    git diff @{u}
    if git diff @{u} | rg -i "(TODO|mydebug)"
        # "y/" means you need to press "y" to confirm to push, anything else is cancel.
        echo "TODO/mydebug spotted. Are you sure you want to push? (y/)"
        read resp
        if test "$resp" != y
            return
        end
    end

    echorun "git push origin $branch --set-upstream origin/$branch"  
end  

# gitpush, and create a draft pull request.
function gitpushpullrequestdraft
    gitpush
    set branch (gitbranch | sed 's/.*\///')
    echo
    gh pr create --label "pending/gitpushjoe" -t $branch" "(ticketdescription $branch) --fill --draft
end

# gitpush, and create a pull request.
function gitpushpullrequest
    gitpush
    set branch (gitbranch | sed 's/.*\///')
    echo
    gh pr create --label "pending/gitpushjoe" -t $branch" "(ticketdescription $branch) --fill
end

alias gp=gitpush  
alias gpr=gitpushpullrequest
alias gprd=gitpushpullrequestdraft
alias gl="ql git log -n 128 --color=always --decorate=full"

function q
    # TODO: link pathdown
    unbuffer $argv | luajit /home/ubuntu/pathdown/pathdown.lua
    source /home/ubuntu/pathdown/pathdown.fish
end

function pd
    # TODO: link pathdown
    luajit /home/ubuntu/pathdown/pathdown.lua
    source /home/ubuntu/pathdown/pathdown.fish
end

function ql
    # TODO: link pathdown
    $argv | luajit /home/ubuntu/pathdown/pathdown.lua | less -FRSX
    source /home/ubuntu/pathdown/pathdown.fish 
end

# git status wrapper that uses pathdown
alias gs="bash -c '( ( git -c color.status=always status $argv ) | luajit /home/ubuntu/pathdown/pathdown.lua ) | less -FSR' && source /home/ubuntu/pathdown/pathdown.fish"  

# git commit wrapper that always git diff's as well
# If I hit 'Enter', then I will be sent to the interactive commit description editor, with the ticket-name autofilled in
# If I include some text, it will be used as the commit name, with the ticket-name included at the beginning
# uses pathdown
alias gc='git diff --cached --color=always | luajit /home/ubuntu/pathdown/pathdown.lua | less -FSR; git diff --cached | rg -i "(TODO|mydebug)"; printf "Looks good? (/n): \n"; echo; read resp; 
if test "$resp" != n
    if test -z "$resp"
        git commit --edit -m (printf \'%s \' (gitbranch | sed \'s/.*\///\'))
        return
    else
        git commit -m (printf \'%s %s\' (gitbranch | sed \'s/.*\///\') "$resp")
    end
end; 
return;'

# git commit all
alias gca='git add . && gc'

# git diff wrapper that uses pathdown
alias gd="bash -c 'git diff --color=always $argv | luajit /home/ubuntu/pathdown/pathdown.lua | less -FSR'; source /home/ubuntu/pathdown/pathdown.fish"

# git diff --cached wrapper that uses pathdown
alias gdc="bash -c 'git diff --cached --color=always $argv | luajit /home/ubuntu/pathdown/pathdown.lua | less -FSR'; source /home/ubuntu/pathdown/pathdown.fish"

alias garc="git add . && git rebase --continue"
alias grc="git rebase --continue"

# git checkout wrapper for my branches
function gch
    if not git checkout $argv[1] 2>/dev/null
        # gross, but i have no idea how else to make this work:
        set cmd "git checkout"(git branch | grep $argv[1] | head -1 | tr -s ' ')
        echorun $cmd
    end
end

# git checkout -b wrapper
function gchb
    git checkout -b $argv[1]
end
# git rebase -i drop all tickets that aren't from this branch (very dangerous, not really sure if it works)
function grbd
    GIT_SEQUENCE_EDITOR="sed -i -n '/"(gitbranch | sed 's/.*\///')"/Ip'" git rebase -i master
end
  
# forgot what this does
function g
    set remote_url (git config --get remote.origin.url)  
    set branch (git rev-parse --abbrev-ref HEAD)  
    set branch (string replace ":" "/" $branch)  
  
    if test -z "$remote_url" -o -z "$branch"  
        echo "Not a Git repository or missing remote."  
        return 1  
    end  
  
    # Convert SSH or HTTPS Git URL to web URL  
    set web_url (string replace "git@" "https://" $remote_url)  
    set web_url (string replace ".git" "" $web_url)  
    set web_url "$web_url/tree/$branch"  
    echo "$web_url"  
end  
  
set -x BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

if not contains $lib_path $LD_LIBRARY_PATH
    if set -q LD_LIBRARY_PATH
        set -x LD_LIBRARY_PATH $LD_LIBRARY_PATH $lib_path
    else
        set -x LD_LIBRARY_PATH $lib_path
    end
end


function fish_prompt  
    # Attempt to retrieve the current Git branch, or fallback with an empty string  
    set PS1_CMD1 (git branch --show-current 2>/dev/null)  
    if test -n "$PS1_CMD1"  
        set PS1_CMD1 (echo $PS1_CMD1 | sed 's/gitpushjoe/joe/')  
    else  
        set PS1_CMD1 ""  # Ensure PS1_CMD1 doesn't carry excessive data  
    end  
  
    # Check for virtual environment  
    set VENV ""  
    if test -n "$VIRTUAL_ENV"  
        set VENV " (venv)"  
    end  
  
    # Assemble the prompt  
    printf "\e[92m╭ \e[38;5;123m%s \e[92m• \e[38;5;123m%s \e[92m• \e[38;5;123m%s%s" (whoami) (date +"%T") (pwd) $VENV  
  
    if test -n "$PS1_CMD1"  
        printf " \e[92m• \e[38;5;218m%s" $PS1_CMD1  
    end  
  
    printf "\n    \e[92m╰─ \e[38;5;214;1m\$ \e[0m"  
end  

function fish_postexec --on-event fish_postexec
    # Print an additional newline after the mode rendering
    echo
end

# edit this file, and then reload the config
function ns
    /usr/local/bin/nvim ~/.config/fish/config.fish && source ~/.config/fish/config.fish  
end  

function c
    clear
end

# use find to search for a file (should refactor)
function vim
    # /usr/local/bin/nvim (find . -path "*$argv[1]*" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2 | head -1)
    /usr/local/bin/nvim (fd | fzf --filter "$argv[1]" | head -1)
end

# Search through Nvim oldfiles
function neo
    # If no arguments are passed, run Neovim  
    if [ (count $argv) -eq 0 ]  
        /usr/local/bin/nvim .
    else  
        # Argument passed, so we want to search Neovim oldfiles  
        set QUERY $argv[1]  
  
        # Use nvim's built-in Lua to search through oldfiles  
        /usr/local/bin/nvim -c "  
        lua  
        -- Function to find a match by progressively trimming the end of the filenames  
        local oldfiles = vim.v.oldfiles  
        oldfiles[501] = nil  
        function find_matching_oldfile(target)  
          -- Get the old files from vim.v.oldfiles  
          local match = nil  
  
          -- Iterate over all old files  
          for _, file in ipairs(oldfiles) do  
            -- We keep trimming characters from the end of the file name  
            while #file > 0 do  
              if not file:find('%.git') and file:find(target) then  
                match = file  
                break  
              end  
              -- Remove one character from the end of the string  
              file = file:sub(1, -2)  
            end  
            -- If we found a match, break the loop  
            if match then  
              break  
            end  
          end  
          return match  
        end  
  
        -- Example usage: Find a file by progressively trimming  
        local match = find_matching_oldfile('$QUERY')  
        if match then  
            vim.cmd('edit ' .. vim.fn.fnamemodify(match, ':p'))  
        end  
        "  
    end  
end  

# why did i do this
function neon
    /usr/local/bin/nvim
end


# cd & open nvim
function cnv
    cd $argv[1] 
    nv .
end

# nv <- readlink <- which
function nvrw
    nv (readlink (which $argv[1]) || which $argv[1])
end

# open neovim config
function nvc
    nv ~/.config/nvim
end

# cd & open neovim config
function cdnvc
    cnv ~/.config/nvim
end

function nuke
    gs
    echo "are you sure? (y/)"
    read resp
    if test "$resp" != y
        return
    end
    git reset --hard
    git clean -fd
end

function portkill
    if test (count $argv) -ne 1
        echo "usage: portkill <port>"
        return 1
    end

    set port $argv[1]

    lsof -ti tcp:$port | xargs -r kill -9
end

function undock
    docker kill (docker ps | awk '{ print $1 }')
    docker system prune --all
end

function undocky
    yes | undock
end

function dockxplode
    sudo service docker stop
    sudo rm -rf /var/lib/docker/
    sudo service docker start
    undocky
end

alias !!="eval (history | head -16 | grep -v '!!' | head -1)"

function tmpf
    set tmp (mktemp)
    printf "%s\n" $argv > $tmp
    echo $tmp
end

alias node=/home/ubuntu/.nvm/versions/node/v19.0.0/bin/node

alias wezterm='flatpak run org.wezfurlong.wezterm'

if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) >/dev/null
end

if not ssh-add -l >/dev/null 2>&1
    if test -f ~/.ssh/id_ed25519
        echo hi
        ssh-add ~/.ssh/id_ed25519
    else if test -f ~/.ssh/id_rsa
        echo hi2
        ssh-add ~/.ssh/id_rsa
    end
end

function gap
    git add -p
end

# 🤫
test -f ~/.config/fish/secret.fish && source ~/.config/fish/secret.fish
test -f ~/.config/fish/work.fish && source ~/.config/fish/work.fish

