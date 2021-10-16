# Miscellaneous Stuff

## Keyboard Remapping

- Defining some shotcuts could be useful! Leave this for your own!

## Daemons

- Daemons: a series processes that are always running in the background rather than waiting for a user to launch them and interact with them.
- Examples
  - `sshd`: listening to incoming SSH requests and checking the remote user has the necessary credentials to log in.
  - `systemd` on Linux: running and setting up daemon processes
    - `systemctl status` list the current running daemons
    - a fairly accessible interface for configuring and enabling new daemons
    - `cron` can also be used to run some program with a given frequency

```bash
# /etc/systemd/system/myapp.service
[Unit]
Description=My Custom App
After=network.target

[Service]
User=foo
Group=foo
WorkingDirectory=/home/foo/projects/mydaemon
ExecStart=/usr/bin/local/python3.7 app.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

## FUSE

- Filesystem in User Space allows filesystems to be implemented by a user program.
- Examples
  - `sshfs`: open locally remote files/folder through an SSH connection
  - `rclone`: mount cloud storage services like Dropbox, GDrive, Amazon S3 or Google Cloud Storage and open data locally
  - ...

## Backups

- Backup your data regularly to avoid losing them accidentally!
  - versioning
  - deduplication
  - security

## APIs

- Many web servers provide certain types of APIs, which could be accessed by `curl`.
- Return data is in `json` format, which could be processed by `jq`.
- Some APIs require authentification, which usually takes some form of secret token to be included with the request.
  - "OAuth" is a common protocol for this authentification

## Command-line Arguments

- `--help` will print helping information
- `--version` or `-V` will have the program print its version
- `--verbose` or `-v` will produce more verbose output. `-vvv` can get even more verbose output
- `--quiet` can make the program only print something on error
- Some programs that would make some irreversible changes would have a `dry run` flag to show what it would have done if you do not set `dry run`
- `-I` can use interactive mode
- Some destructive tools are generally not recursive by default, you can pass `-r` to make them recurse. (like `rm -rf` or `copy`)
- Some programs that are asking for a file name can accpet the filename to be `-`, which means the `STDIN` or `STDOUT`
- Sometimes we don't want things like `-i` to be interpreted as an command line argument, we can add `--` before that. E.g. `rm -- -r` to delete a file called `-r`.

## Window Managers

- Tiling window managers on Linux will arrange your window automatically

## VPNs

- Using an VPN basically means you are shifting your trust from the current Internet Service Provider(ISP) to the VPN provider.
- These days, much of your network traffic is already encrypted through HTTPS or TLS. The network operator will only learn about what servers you talk to, but not anything about the data you exchange.
- However, VPN providers are likely to misconfigure their software so that **the encryption is weak or even disabled**. They should be assumed to log your traffic and sell your information.
- A safer way:
  - Pruchase a VPS
  - Set up your own

## Markdown

- Well, I'm using markdown to write this note.

## Hammerspoon

- Hammerspoon lets you run arbitrary **Lua** code, bound to menu buttons, key presses and events
- Especially useful for MacOS to (on Windows, it's already available on the OS)
  - bind hotkeys to move windows to specific locations
  - create a menu bar button that automatically lays out windows in a specific layout (lab/gaming/entertainment/...)
  - mute the speaker by detecting the WiFi network

## Booting + Live USBs

- Before the operating is loaded when the machine boots up, **BIOS/UEFI** initializes the system. 
  - You can configure all sorts of hardware-related settings in the **BIOS menu**.
  - You can also enter the boot menu to boot from an alternate device instead of the hard drive.
- **Live USBs** are USB flash drives containing an operating system (like a Linux distribution). There are tools that help you create live USBs
  - Can be used to fix the operating system when it has some problem and no longer boots.

## Network Programming

- **Jupyter Notebook** is great!