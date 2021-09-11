# Shell Tools and Scripting

## Shell Scripting

* Why shell scripting?

  * Optimized for performing shell-related tasks than other general programming languages
    * Creating command pipelines
    * Saving results into files
    * Reading from standard input

* Assign variable in bash: `foo=bar`, `foo = bar` will not work because foo would be interpreted as a program.

* Define string with '' or "":

  ```bash
  foo=bar
  echo "$foo"
  # prints bar
  echo '$foo'
  # prints $foo
  ```

* Define functions

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

* Special Variables

  * `$0`: Name of the script
  * `$1` to `$9`: Arguments to the script. `$1` is the first argument
  * `$@`: All the arguments
  * `$#`: Number of arguments
  * `$?`: Return code of the previous command
  * `$$`: Process indentification number (PID) for the current script 
  * `!!`: Entire last command, including arguments. A common pattern is to execute a command only for it to fail due to missing permissions; you can quickly re-execute the command with sudo by doing `sudo !!`
  * `$_`: Last argument from the last command. If you are in an interactive shell, you can also quickly get this value by typing `Esc` followed by `.`

  * More can be found [here](https://tldp.org/LDP/abs/html/special-chars.html).

