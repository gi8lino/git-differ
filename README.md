# git diff utility

Perform a `git diff -stat` in `PATH`, or in multiple `PATHS`.  
All parameters starting with `--` will be pass to the `git diff` command and the default parameter `--stat` will be removed.

## usage

```bash
git-differ.sh [-s|--skip]
              [-a|--all]
              [-m|--maxdepth LEVELS]
              [-e|--exclude "[DIRECTORY ...]" ]
              PATH [PATH ...]
```

## arguments

### positional arguments

| parameter    | description                                    |
| ------------ | ---------------------------------------------- |
| `[PATH ...]` | path or multiple paths to perform a `git diff` |

### optional parameters

| parameter                         | description                                                                       |
| ----------------------------------| --------------------------------------------------------------------------------  |
| `-s`, `--skip`                    | do not show repositories without diff                                             |
| `-a`, `--all`                     | descend over all directories in `[PATH ...]`"                                     |
| `-m`, `--maxdepth` [LEVELS]       | descend at most levels (a non-negative integer) of directories below `[PATH ...]`<br>if set, it ignores `-a`, `--all |
| `-e`, `--exclude` [DIRECTORY ...] | do not descend into this directory(s)<br>list of strings, separated by a space and surrounded by quotes (case sensitive)` |
| `-h`, `--help`                    | display this help and exit                                                        |
| `-v`, `--version`                 | output version information and exit                                               |
