# Debugging and Profiling

## Debugging

### Better than Print: Logging

- Logging is better than print statements because:
  - You can log to files, sockets or even remote servers instead of just STDOUT
  - Logging supports severity levels that would allow you to filter the output accordingly
  - When new issues occur, it's likely that your logs already contain the necessary information to solve it without adding new print statements
  - Color coded logs make them readable
    - Programs like `ls` or `grep` use ANSI escape codes to change the color of the output

### Third Party Logging

- When building large software systems, you will have dependencies like web servers, databases or message brokers. You will need to read their logs to debug these separate programs.
- Most programs will write their logs in the system. In UNIX, programs will write logs under `/var/log`.
- Systems also have a **system log**. Most Linux systems use `systemd` to control many things in your system such as which services are enabled and running. The log is put in
  - On Linux, `/var/log/journal`. You can use `journalctl` to display the messages.
  - On MacOS, `/var/log/system.log`
- `log show` can also display the system log.
- A demo:

```bash
logger "Hello Logs"
# On macOS
log show --last 1m | grep Hello
# On Linux
journalctl --since "1m ago" | grep Hello
```

### Debuggers

- `pdb` for Python, very similar to `gdb`.

```bash
python -m pdb ScriptToDebug.py
```

- `ipdb`: an improved version of `pdb`

### Specialized Tools

- Even when debugging a black box binary, there are commands to debug the system calls the program make.
  - `strace` on Linux
  - `dtrace` on macOS and BSD, but it can be tricky to use because it uses `D` language `dtruss` provides a similar interface to `strace`.
  - A demo:

```bash
# On Linux
sudo strace -e lstat ls -l > /dev/null
4
# On macOS
sudo dtruss -t lstat64_extended ls -l > /dev/null
```

- To debug network packets: `tcpdump` and `Wireshark`
- For web development: the Chrome and Firefox developer tools

### Static Analysis

- Some issues could be found without running the code
- `pyflake` and `mypy`

```bash
$ pyflakes foobar.py
foobar.py:6: redefinition of unused 'foo' from line 3
foobar.py:11: undefined name 'baz'

$ mypy foobar.py
foobar.py:6: error: Incompatible types in assignment (expression has type "int", variable has type "Callable[[], Any]")
foobar.py:9: error: Incompatible types in assignment (expression has type "float", variable has type "int")
foobar.py:11: error: Name 'baz' is not defined
Found 3 errors in 1 file (checked 1 source file)
```

- Most editors and IDEs support output of these tools within the editor itself, highlighting the locations of warnings and errors. This is called **code linting**
- There are also some **stylistic linting** tools:
  - `black` for Python
  - `gofmt` for Go
  - `rustfmt` for Rust
  - `prettier` for Javascript, HTML and CSS

## Profiling

Profiling is to understand which part of your code are taking most of the time and resources so that you can focus on optimizing those parts.

### Timing

- Use `time` module to print the time it took between two points

```bash
import time, random
n = random.randint(1, 10) * 100

# Get current time
start = time.time()

# Do some work
print("Sleeping for {} ms".format(n))
time.sleep(n/1000)

# Compute time between start and now
print(time.time() - start)

# Output
# Sleeping for 500 ms
# 0.5713930130004883
```

- However, wall clock time could be misleading because the computer might be running other processes at the same time or waiting for some events to happen. Some tools can make a distinction between **Real**, **User** and **Sys** time. **User** + **Sys** time tells you how much time your process actually spent in the CPU.
  - **Real** - Wall clock elapsed time from start to finish of the program, including the time taken by other processes and time taken while blocking
  - **User** - Amount of time spent in the CPU running user code
  - **Sys** - Amount of time spent in the CPU runnig kernel code

```shell
$ time curl https://missing.csail.mit.edu &> /dev/null
real    0m2.561s
user    0m0.015s
sys     0m0.012s
```

### CPU Profilers

- **Tracing profilers**: keep a record of every function call your program makes
- **Samling profilers**: probe the program periodically and record the program's stack 
- In Python we can use `cProfile` to profile time per function call: 

```python
#!/usr/bin/env python

import sys, re

def grep(pattern, file):
    with open(file, 'r') as f:
        print(file)
        for i, line in enumerate(f.readlines()):
            pattern = re.compile(pattern)
            match = pattern.search(line)
            if match is not None:
                print("{}: {}".format(i, line), end="")

if __name__ == '__main__':
    times = int(sys.argv[1])
    pattern = sys.argv[2]
    for i in range(times):
        for file in sys.argv[3:]:
            grep(pattern, file)
```

```shell
$ python -m cProfile -s tottime grep.py 1000 '^(import|\s*def)[^,]*$' *.py

[omitted program output]

 ncalls  tottime  percall  cumtime  percall filename:lineno(function)
     8000    0.266    0.000    0.292    0.000 {built-in method io.open}
     8000    0.153    0.000    0.894    0.000 grep.py:5(grep)
    17000    0.101    0.000    0.101    0.000 {built-in method builtins.print}
     8000    0.100    0.000    0.129    0.000 {method 'readlines' of '_io._IOBase' objects}
    93000    0.097    0.000    0.111    0.000 re.py:286(_compile)
    93000    0.069    0.000    0.069    0.000 {method 'search' of '_sre.SRE_Pattern' objects}
    93000    0.030    0.000    0.141    0.000 re.py:231(compile)
    17000    0.019    0.000    0.029    0.000 codecs.py:318(decode)
        1    0.017    0.017    0.911    0.911 grep.py:3(<module>)

[omitted lines]
```

We can see that IO is taking most of the time and compiling the regex also takes a fair amount of time. However, `cProfile` profiler display time per function call, which might be unintuitive.

- **Line profilers** can display the time taken per line:

```python
#!/usr/bin/env python
import requests
from bs4 import BeautifulSoup

# This is a decorator that tells line_profiler
# that we want to analyze this function
@profile
def get_urls():
    response = requests.get('https://missing.csail.mit.edu')
    s = BeautifulSoup(response.content, 'lxml')
    urls = []
    for url in s.find_all('a'):
        urls.append(url['href'])

if __name__ == '__main__':
    get_urls()
```

```bash
$ kernprof -l -v a.py
Wrote profile results to urls.py.lprof
Timer unit: 1e-06 s

Total time: 0.636188 s
File: a.py
Function: get_urls at line 5

Line #  Hits         Time  Per Hit   % Time  Line Contents
==============================================================
 5                                           @profile
 6                                           def get_urls():
 7         1     613909.0 613909.0     96.5      response = requests.get('https://missing.csail.mit.edu')
 8         1      21559.0  21559.0      3.4      s = BeautifulSoup(response.content, 'lxml')
 9         1          2.0      2.0      0.0      urls = []
10        25        685.0     27.4      0.1      for url in s.find_all('a'):
11        24         33.0      1.4      0.0          urls.append(url['href'])
```

### Memory Profilers

- For languages where memory leaks might happen, consider using `Valgrind`
- In garbage collected languages like Python, memory profilers are still useful:

```python
@profile
def my_func():
    a = [1] * (10 ** 6)
    b = [2] * (2 * 10 ** 7)
    del b
    return a

if __name__ == '__main__':
    my_func()
```

```bash
$ python -m memory_profiler example.py
Line #    Mem usage  Increment   Line Contents
==============================================
     3                           @profile
     4      5.97 MB    0.00 MB   def my_func():
     5     13.61 MB    7.64 MB       a = [1] * (10 ** 6)
     6    166.20 MB  152.59 MB       b = [2] * (2 * 10 ** 7)
     7     13.61 MB -152.59 MB       del b
     8     13.61 MB    0.00 MB       return a
```

### Event Profiling

- [perf](https://www.man7.org/linux/man-pages/man1/perf.1.html) command reports system events related to your programs like poor cache locality, high amount of page faults or livelocks.
  - `perf list` - List the events that can be traced with perf
  - `perf stat COMMAND ARG1 ARG2` - Gets counts of different events related a process or command
  - `perf record COMMAND ARG1 ARG2` - Records the run of a command and saves the statistical data into a file called `perf.data`
  - `perf report` - Formats and prints the data collected in `perf.data`

### Visualization of Profilers' Output

- **Flamegraph** visualize the time taken for each function call
- **Call graphs** or **control flow graphs** visualize the relationships betweem subroutines within a program.

### Resource Montioring

- **General Monitoring**
  - `htop` is an improved version of `top`. `htop` presents statistics for currently running processes on the system.
    - `<F6>` sort processes
    - `t` show tree hierarchychy
    - `h` show the help screen 
  - [glance](https://nicolargo.github.io/glances/)
  - [dstat](http://dag.wiee.rs/home-made/dstat/)
- **I/O Operations**
  - `iotop`: display live I/O usaging information. Useful to check if a process is doing heavy I/O disk operations
- **Disk Usage**
  - `df` display metrics per partitions
  - `du -h` display disk usage per file for the current directory in a human-readable format
- **Memory Usage**
  - `free` display free and used memory in the system
- **Open Files**
  - `lsof` lists file information about files opened by processes, can be used to check which process has opened  a specific file
- **Network Connections and Configs**
  - `ss` monitor incoming and outgoing network packets statistics, can be used to figure out what process is using a given port at a given machine
  - `ip` to display routing, network devices and interfaces
- **Network Usage**
  - `nethogs` and `iftop`: interative CLI tools for monitoring network usage

- Testing monitoring tools
  - Use `stress` to artificially impose loads on the machine

### Specialized Tools

- Block box benchmarking to determine what software to use:
  - An example to compare between `fd` and `find`

```shell
$ hyperfine --warmup 3 'fd -e jpg' 'find . -iname "*.jpg"'
Benchmark #1: fd -e jpg
  Time (mean ± σ):      51.4 ms ±   2.9 ms    [User: 121.0 ms, System: 160.5 ms]
  Range (min … max):    44.2 ms …  60.1 ms    56 runs

Benchmark #2: find . -iname "*.jpg"
  Time (mean ± σ):      1.126 s ±  0.101 s    [User: 141.1 ms, System: 956.1 ms]
  Range (min … max):    0.975 s …  1.287 s    10 runs

Summary
  'fd -e jpg' ran
   21.89 ± 2.33 times faster than 'find . -iname "*.jpg"'
```

