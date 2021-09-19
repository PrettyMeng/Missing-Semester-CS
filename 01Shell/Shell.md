# Shell

## Navigating The Shell

* Using phrases as arguments: quote the argument with `'` or `"`, or escape just the relevant characters with `\`.
* `.`: Current directory `..`: Parent directory
* `cd -`: Change directory back and forth between two
* `ls -l`: List files in long format
  * Same function with `ll`
  * Presenting file permissions for the user, the user group and anyone else with `rwx`. And the `d` at the beginning of these `rwx` groups indicates this is a directory.
  * For directory permissions:
    * Read: Whether it is allowed to "list" files in it.
    * Write: Whether it is allowed delete/rename/create files in it. **If the directory does not have the write permission but the certain file has, we can make it empty, but just cannot delete it.**
    * Executable: Whether it is allowed to enter the directory.
* `rmdir`: Remove the directory only if it is empty. So it is a safe way to delete directory.

* `man ls`: Show the mannual page of ls. **man takes an argument of the program name to show its mannual page**

* `ctrl+L`: Clean up the terminal and go back to the top

## Connecting Programs

* Two streams in the shell: input stream and output stream.

  * Input Stream: When the program tries to read input, it **reads from the input stream**. (Keyboard)
  * Output Stream: When the program prints something, it **prints to the output stream**. (Screen)

* Redirection

  * `< fileA`: input from fileA
  * `> fileB`: output to fileB
  * `>> fileC`: append to fileC instead of just overwrite

* Pipe: The output in the left is the input of the right

  * Print the last line of `ls -l /`'s output

    ```Bash
    missing:~$ ls -l / | tail -n1
    drwxr-xr-x 1 root  root  4096 Jun 20  2019 var
    ```

  * Get the content-length of an http response. Select the second field of the space.

    ```bash
    missing:~$ curl --head --silent google.com | grep --ignore-case content-length | cut --delimiter=' ' -f2
    219
    ```
	The `cut` command is a little different in MACOSX.
	```bash
	missing:~$ curl --head --silent google.com | grep --ignore-case content-length | cut -d ' ' -f2
	219
	```

## A Vertatile and Powerful Tool

* The "root" user: above all access restrictions, and can create, read, update, and delete any file in the system.

  * To prevent accidental breakdown
  * `sudo` lets you do something "as superuser".

* Use sudo properly:

  ```bash
  $ sudo find -L /sys/class/backlight -maxdepth 2 -name '*brightness*'
  /sys/class/backlight/thinkpad_screen/brightness
  $ cd /sys/class/backlight/thinkpad_screen
  $ sudo echo 3 > brightness
  An error occurred while redirecting file 'brightness'
  open: Permission denied
  ```

  The error occurs because `|`, `<`, `>` are done by the shell, not the program. The shell still does not have the permission. We can work around in this way:

  ```bash
  echo 3 | sudo tee brightness
  ```

  or

  ```bash
  sudo su
  echo 3 > brightness
  ```

  to get your shell as the superuser and be able to write to `sysfs`

* Could be used to write to the `sysfs` to configure some kernel parameter of your computer. **Note that sysfs does not exist on Windows or MacOS.**

  ```bash
  echo 1 | sudo tee /sys/class/leds/input6::scrolllock/brightness
  ```


## Additional commands

* `tee` -- pipe fitting. The tee utility copies standard input to standard output, making a copy
     in zero or more files.

* `curl` -- transfer a URL. The curl utility is a tool to transfer data from or to a server, using one of the
       supported protocols, such as FTP, HTTP, SMTP.

* `grep` -- file pattern searcher. The grep utility searches any given input files, selecting lines that
     match one or more patterns.

* `tail` -- display the last part of a file. The tail utility displays the contents of file or, by default, its stan-
     dard input, to the standard output.

* `cut` -- cut out selected portions of each line of a file. The cut utility cuts out selected portions of each line (as specified by
     list) from each file and writes them to the standard output.

* The difference between `sudo` and `su`: `Sudo` runs a single command with root privileges, while `su` switches you to the root user account and requires the root account’s password.


## Exercise

* Write #!/bin/sh to a file named semester:

  ```bash
  echo '#!/bin/sh' > semester
  ```

* Use `chmod` to add execution permissions

  ```bash
  chmod +x semester
  ```

* Use commands to read the battery of the laptop

  ```bash
  cat /sys/class/power_supply/BAT1/capacity
  ```

  
