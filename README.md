# git diff utility

Perform a `git diff --stat` in one or more (sub)directories.  
All parameters starting with `--` will be passed to the `git diff` command and the default parameter `--stat` will be removed.

## usage

```bash
git-differ.sh [-s|--skip]
              [-r|--recursive]
              [-m|--maxdepth LEVELS]
              [-e|--exclude "[DIRECTORY ...]" ]
              PATH [PATH ...]
```

## arguments

### positional arguments

| parameter    | description                                     |
| ------------ | ----------------------------------------------- |
| `[PATH ...]` | one or more directories to perform a `git diff` |

### optional parameters

| parameter                           | description                                                                       |
| ----------------------------------- | --------------------------------------------------------------------------------  |
| `-s`, `--skip`                      | do not show repositories without diff                                             |
| `-r`, `--recursive`                 | iterate over directories and all their subdirectories recursively                 |
| `-m`, `--maxdepth` `LEVELS`         | iterate over directories and their subdirectories until the set `LEVELS` is reached (a non-negative integer)<br>if set, it ignores `-r|--recursive` |
| `-e`, `--exclude` `[DIRECTORY ...]` | do not descend into this directory(s)<br>list of strings, separated by a space and surrounded by quotes (case sensitive) |
| `-h`, `--help`                      | display this help and exit                                                        |
| `-v`, `--version`                   | output version information and exit                                               |
