# Data Wrangling

## `sed` + regular expressions

### Regular Expressions 

- Common patterns
  - `.` any single character except newline
  - `*` zero or more of the preceding match
  - `+` one or more of the preceding match
  - `[abc]` any one character of `a` `b` and `c`  `[^abc]` any character excluding `a` `b` and `c`
  - `\d` any digit   `\D` any non-digit character
  - `\w` any alphanumeric character    `\W` any non-alphanumeric character
  - `{m}` m repetitions    `{m, n}`  m to n repetitions
  - `\s` any whitespace  `\S` any non-whitespace character
  - `(RX1|RX2)` either something that matches RX1 or RX2
  - `^` the start of the line   `$` the end of the line

### sed Basic Usage

- `sed 's/.*Disconnected from //'`
  - `s/REGEX/SUBSTITUITION/`
    - `s` stands for substitution
    - `REGEX` some pattern you want to match
    - `SUBSTITUTION` the text you want to substitute matching text with
  - A tricky case: `Jan 17 03:13:00 thesquareplanet.com sshd[2631]: Disconnected from invalid user Disconnected from 46.97.239.16 port 55920 [preauth]`
    - Some user named "Disconnected from"
    - `*`, `+` does greedy matching
- Pass `-E` to avoid putting `\` before some special characters 
- Capture groups
  - a regex surrounded by parentheses is stored in a numbered capture group `\1`, `\2`, ...



## Data Wrangling Tools

### Small Tools

- `sort` sort its input
- `uniq -c` collapse consecutive lines that are the same into a single line, prefixed with a count of the number of occurrences
- `paste -sd,` combine lines by a single character specified by `-d{char}` 

### awk - another editor

- `awk {print $2}` print the second field of the delimeter, delimeter can be specified by `-F` 

- ` awk '$1 == 1 && $2 ~ /^c[^ ]*e$/ { print $2 }' | wc -l` specify a pattern: the first field in the line should be 1, the second field should match the regular expression. `wc -l` to count the number of lines that match such pattern

- `awk` as a programming language

  ```bash
  BEGIN { rows = 0 }
  $1 == 1 && $2 ~ /^c[^ ]*e$/ { rows += $1 }
  END { print rows }
  ```

### Analyzing data

- `bc -l` can do basic calculation
- Can also combine `R` and `gnuplot` to do more advanced data analysis and plots

