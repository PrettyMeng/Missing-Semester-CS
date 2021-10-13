# Command Line Environment

## Job Control

### Killing a process

- `Ctrl-C`: sending `SIGINT`
- `Ctrl-\`: sending `SIGQUIT`
- `kill -TERM <PID>`: use `kill` command to send `SIGTERM` signal

### Pausing and backgrounding processes

- `Ctrl-Z`: sending `SIGSTP`, to pause a process

  - Background an already running program: `Ctrl-Z`, then `bg`

- `fg` or `bg` can continue the paused job in the foreground or in the background

- `pgrep` look up for processes based on name or other attributes. [more about this](https://www.man7.org/linux/man-pages/man1/pgrep.1.html)

- `nohup` to ignore `SIGHUP`

  ```bash
  $ nohup sleep 2000 &
  [2] 18745
  appending output to nohup.out
  ```

- `SIGKILL` cannot be killed by the process and it will always terminate it immediately, but it's risky of leaving orphaned childen processes.

## Terminal Multiplexers

### tmux: run more than one thing at once

- **Sessions**: an independent workspace with one or more windows
  - `tmux` starts a new session
  - `tmux new -s NAME` starts a session with that name
  - `tmux ls` lists current sessions
  - `tmux a` attaches the last session, use `-t` to specify which one
  - `Ctrl-b` + `d` detaches the current session
- **Windows**: visually seperate parts of the same session
  - `Ctrl-b` + `c` creates a window
  - `Ctrl-d` closes the current window
  - `Ctrl-b` + `N` goes to the Nth window
  - `Ctrl-b` + `p` goes to the previous window
  - `Ctrl-b` + `n` goes to the next window
  - `Ctrl-b` + ` '` renames the current window
  - `Ctrl-b` + `w` lists current windows
- **Panes**: have multiple shells in the same visual display (less used)
  - `Ctrl-b` + `"` splits the current window horizontally 
  - `Ctrl-b` + `%` splits the current window vertically
  - `Ctrl-b` + `<direction>` move to the pane in the corresponding direction
  - `Ctrl-b` + `z` toggle zoom (最小化) the current pane

- About [Screen](https://www.man7.org/linux/man-pages/man1/screen.1.html)

## Alias

- Create a short form for another command, its structure:

```bash
alias alias_name="command_to_alias arg1 arg2"
```

- Several convenient features

```bash
# Make shorthands for common flags
alias ll="ls -lh"

# Save a lot of typing for common commands
alias gs="git status"
alias gc="git commit"
alias v="vim"

# Save you from mistyping
alias sl=ls

# Overwrite existing commands for better defaults
alias mv="mv -i"           # -i prompts before overwrite
alias mkdir="mkdir -p"     # -p make parent dirs as needed
alias df="df -h"           # -h prints human readable format

# Alias can be composed
alias la="ls -A"
alias lla="la -l"
```

- Disable an alias

```bash
# To ignore an alias run it prepended with \
\ls
# Or disable an alias altogether with unalias
unalias la
```

- Get an alias definition

```bash
# To get an alias definition just call it with alias
alias ll
# Will print ll='ls -lh'
```

- Can configure alias in `.bashrc` or `.zshrc`

## Dotfiles

### For configuration

- Configuration files for tools, here are some of them:
  - `bash` - `~/.bashrc`, `~/.bash_profile`
  - `git` - `~/.gitconfig`
  - `vim` - `~/.vimrc` and the `~/.vim` folder
  - `ssh` - `~/.ssh/config`
  - `tmux` - `~/.tmux.conf`

- Benefits:
  - **Easy installation**: if you log in to a new machine, applying your customizations will only take a minute.
  - **Portability**: your tools will work the same way everywhere.
  - **Synchronization**: you can update your dotfiles anywhere and keep them all in sync.
  - **Change tracking**: you’re probably going to be maintaining your dotfiles for your entire programming career, and version history is nice to have for long-lived projects.

- Can refer to others' dotfiles on Github

### Portability

- Machine-specific configuration

```bash
if [[ "$(uname)" == "Linux" ]]; then {do_something}; fi

# Check before using shell-specific features
if [[ "$SHELL" == "zsh" ]]; then {do_something}; fi

# You can also make it machine-specific
if [[ "$(hostname)" == "myServer" ]]; then {do_something}; fi
```

- Sharing alias for different programs (e.g. `bash` and `zsh`)

```bash
# Test if ~/.aliases exists and source it
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
```

## Remote Machines

### Executing commands remotely

- Remote `ls`:

```bash
ssh foobar@server ls
```

- `ls` locally and `grep` remotely

```bash
ls | ssh foobar@server grep PATTERN
```

### SSH Keys

Use public-key cryptography to prove to the server that the client owns the private key without revealing the key.

#### Key generation:

```bash
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

Check if you have a passphrase and validate it, run:

```bash
ssh-keygen -y -f /path/to/key
```

#### Key-based authentification

`ssh` will look into `.ssh/authorized_keys` to determine which clients it should let in. To copy a public key over:

```bash
cat .ssh/id_ed25519.pub | ssh foobar@remote 'cat >> ~/.ssh/authorized_keys'
```

or with `ssh-copy-id`

```bash
ssh-copy-id -i .ssh/id_ed25519.pub foobar@remote
```

#### Copying files over SSH

- `ssh` + `tee` 

```bash
cat localfile | ssh remote_server tee serverfile
```

Notes that `tee` writes the output from STDIN into a file

- `scp` 

```shell
scp path/to/local_file remote_host:path/to/remote_file
```

- `rsync` an improved version of `scp`. 
  - preventing copying the same file
  - provides more fine grained control over symlinks, permissions
  - `--partial` resume from a previous interrupted copy

#### *Port forwarding

- Local port forwarding
- Remote port forwarding
- If we execute `jupyter notebook` in the remote server that listens to the port `8888`. To forwards that to the local port `9999`: `ssh -L 9999:localhost:8888 foobar@remote_server`. Then navigate to `localhost:9999` in our local machine.

#### SSH Configuration

- Use alias

```bash
alias my_server="ssh -i ~/.id_ed25519 --port 2222 -L 9999:localhost:8888 foobar@remote_server
```

- `~/.ssh/config`

```sh
Host vm
    User foobar
    HostName 172.16.174.141
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 9999 localhost:8888

# Configs can also take wildcards
Host *.mit.edu
    User foobaz
```

Other programs like `scp`, `rsync`, `mosh` can read this config and convert it to the corresponding flags.

