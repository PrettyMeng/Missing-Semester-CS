# Shell Tools and Scripting

## Shell Scripting

### Why shell scripting?

* Optimized for performing shell-related tasks than other general programming languages
  * Creating command pipelines
  * Saving results into files
  * Reading from standard input

### Assign variable in bash

*  `foo=bar`, `foo = bar` will not work because foo would be interpreted as a program.

### Define string with '' or "":

```bash
foo=bar
echo "$foo"
# prints bar
echo '$foo'
# prints $foo
```

### Define functions

*  let's say we have a file named mcd.sh:

```bash
mcd () {
    mkdir -p "$1"
    cd "$1"
}
```

* Then we can do the following:

```bash
source mcd.sh
mcd test
```

This will `mkdir` a directory named test and `cd` into it.

### Special Variables

* `$0`: Name of the script
* `$1` to `$9`: Arguments to the script. `$1` is the first argument
* `$@`: All the arguments
* `$#`: Number of arguments
* `$?`: Return/Error code of the previous command. 0 means everything is OK; anything else means an error occured.
* `$$`: Process indentification number (PID) for the current script 
* `!!`: Entire last command, including arguments. A common pattern is to execute a command only for it to fail due to missing permissions; you can quickly re-execute the command with sudo by doing `sudo !!`
* `$_`: Last argument from the last command. If you are in an interactive shell, you can also quickly get this value by typing `Esc` followed by `.`

* More can be found [here](https://tldp.org/LDP/abs/html/special-chars.html).

### Logical operators with **short-circuiting** features

* `;`: for separating commands

```bash
false || echo "Oops, fail"
# Oops, fail

true || echo "Will not be printed"
#

true && echo "Things went well"
# Things went well

false && echo "Will not be printed"
#

true ; echo "This will always run"
# This will always run

false ; echo "This will always run"
# This will always run
```

### Get the output of a command as a variable/file

* `xargs`: convert `stdin` to command line arguments
  * command line arguments: will not block the shell
  * `stdin` will block the shell if the input is empty

* Command substition: `$(CMD)` will execute `CMD` and substitute it in place
  * e.g. `for file in $(ls)`: Iterate the output of `ls`
* Process substitution: `<(CMD)` will execute `CMD` and place the output in a temporary file and substitute the `<()` with that file's name. Useful when commands expect values to be passed by file instead of STDIN.
  * e.g. `diff <(ls foo) <(ls bar) `: show differences between files in dirs `foo` and `bar`

### A comprehensive example

```bash
#!/bin/bash

echo "Starting program at $(date)" # Date will be substituted

echo "Running program $0 with $# arguments with pid $$"

for file in "$@"; do
    grep foobar "$file" > /dev/null 2> /dev/null
    # When pattern is not found, grep has exit status 1
    # We redirect STDOUT and STDERR to a null register since we do not care about them
    if [[ $? -ne 0 ]]; then
        echo "File $file does not have any foobar, adding one"
        echo "# foobar" >> "$file"
    fi
done
```

* `> /dev/null` and `2> /dev/null` for not printing STDOUT and STDERR
* Use double brackets `[[]]` when performing comparisons.

### Shell *globbing*

* Wildcard

  * `?`: One character
  * `*`: Zero or more character
  * Given files `foo`, `foo1`, `foo2`, `foo10` and `bar`
    * `rm foo?`: will delete `foo1` and `foo2`
    * `rm foo*`: will delete all but `bar`

* Curly braces `{} `: expand a common substring automatically

  * ```bash
    convert image.{png,jpg}
    # Will expand to
    convert image.png image.jpg
    ```

  * ```bash
    cp /path/to/project/{foo,bar,baz}.sh /newpath
    # Will expand to
    cp /path/to/project/foo.sh /path/to/project/bar.sh /path/to/project/baz.sh /newpath
    ```

  * ```bash
    # Globbing techniques can also be combined
    mv *{.py,.sh} folder
    # Will move all *.py and *.sh files
    ```

  * ```bash
    mkdir foo bar
    # This creates files foo/a, foo/b, ... foo/h, bar/a, bar/b, ... bar/h
    touch {foo,bar}/{a..h}
    touch foo/x bar/y
    # Show differences between files in foo and bar
    diff <(ls foo) <(ls bar)
    # Outputs
    # < x
    # ---
    # > y
    ```

### [Shellcheck](https://github.com/koalaman/shellcheck) 

* To help you find errors in sh/bash scripts

### Shebang

* Shell scripts are not necessarily be written in bash, use **shebang** to specify the interpreter

  ```bash
  #!/usr/local/bin/python
  import sys
  for arg in reversed(sys.argv[1:]):
      print(arg)
  ```

* A better practice is to specify the interpreter using the `env` command: `#!/usr/bin/env python` to resolve the location automatically

### Difference between functions and scripts

* Functions have to be in the same language as the shell, while scripts can be written in any language. This is why including a shebang for scripts is important.
* Functions are executed in the current shell environment whereas scripts execute in their own process. Thus, functions can modify environment variables, e.g. change your current directory, whereas scripts can’t. Scripts will be passed by value environment variables that have been exported using `export`.

## Shell Tools

### Documentation about how to use commands

* `-h` or `--help`: brief introduction about how to use
* `man`: full documentation, but may be overly detailed
* `tldr`: a more nifty solution, provide several common examples

### Finding files matching some criteria

* `find`

```bash
# Find all directories named src
find . -name src -type d
# Find all python files that have a folder named test in their path
find . -path '*/test/*.py' -type f
# Find all files modified in the last day
find . -mtime -1
# Find all zip files with size in range 500k to 10M
find . -size +500k -size -10M -name '*.tar.gz'
```

Besides listing files, `find` can also perform actions over files that match the query.

```bash
# Delete all files with .tmp extension
find . -name '*.tmp' -exec rm {} \;
# Find all PNG files and convert them to JPG
find . -name '*.png' -exec convert {} {}.jpg \;
```

* `fd`
```bash
# a simple, fast, and user-friendly alternative to `find`
fd 'PATTERN' = find -name '*PATTERN*'
# Find all python files
fd '.*.py'
```

* `locate`
  * Use a database and thus **faster** to search for files. The database is updated by `updateb`, which is perform daily. 
  * Compared with `find`, **can only search via file name**.

### Finding code

* `grep`
  * `-C`: Getting **C**ontext around the matching line. e.g. `-C 5` will print 5 lines before and after the match.
  * `-v`: In**v**erting the match, print all lines that do not match the pattern
  * `-R`: **R**ecursively go into directories and look for files for the matching string
* `rg` (ripgrep): ignore `.git` folders and using multi CPU support
  * `-t`: Specify a type. e.g. `-t py`	
  * `-u`: Include hidden files
  * `--file-without-matching`:Find files that do not have the pattern
  * `-A`: print the following lines of the pattern
  * Examples:

```bash
# Find all python files where I used the requests library in a specified folder
rg -t py 'import requests' ~/scratch
# Find all files (including hidden files `-u`) without a shebang line
rg -u --files-without-match "^#!"
# Find all matches of foo and print the following 5 lines
rg foo -A 5
# Print statistics of matches (# of matched lines and files )
rg --stats PATTERN
```

### Finding commands

* `histroy`: List your previous commands. 

  * `histroy | grep find` will print commands that contain the substring "find"
  * `histroy 10` will print the previous 10 commands

* `ctrl+R`: search through the histroy with a give substring

* `fzf`: do the fuzzy matching instead of exact matching

  ```bash
  cat example.sh | fzf
  #substringToFind
  ```

* histroy-based autosuggestions: can be enabled in zsh

### Directory navigation

* Several useful tools to browse the file structure:
  * `tree` `ls -R`
  * `broot	`
  * `nnn`: also shows hidden files in the directory

* `fasd`

  Adds a `z` command that you can use to quickly `cd` using a substring of a *frecent* directory. For example, if you often go to `/home/user/files/cool_project` you can simply use `z cool` to jump there

## Exercise

* An `ls` command in the following manner:
  * Includes all files, including hidden files
  * Sizes are listed in human readable format (e.g. 454M instead of 454279954)
  * Files are ordered by recency
  * Output is colorized

```bash
ls -a -h -t -color
```

* Write a simple script defining functions in VSCode:

  Modify **CRLF** to **LF** in the bottom to turn "\r\n" to "\n"

* Testing a file that possibly fails with a loop

  *  *for* ((count=1;;count++))
  * *count=1* ... while true ... ((count++))

  * add one to a variable:
    * a=\$((\$a+1))  
    * a=\$[\$a+1]
    * let a++
    * let a+=1

* Use `xargs` to pass arguments originally separated by '\n'

  ```bash
  find . -type f -name "*.html" | xargs -d '\n'  tar -cvzf html.zip
  ```

* Find the most recent file

  ```bash
  find . -type f | xargs -d '\n' ls -lt | head -1
  find . -type f -print0 | xargs -0 ls -lt | head -1
  ```

  * `-print0` for `find` corresponds to `-0` for `xargs`

