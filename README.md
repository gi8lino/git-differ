# git diff utility

Perform a `git diff` in `PATH`, or in multiple `PATH(S)`.  
All parameters starting with `--` will be pass to the `git diff` command.  
Default `git diff` parameter is `--stat`.  

## usage

```bash
git-differ.sh [-r|--recursive] PATH [PATH ...] | [-h|--help] | [-v|--version]
```

## arguments

### positional arguments

| parameter | description                     |
| --------- | ------------------------------- |
| `PATH`... | path(s) to perform a `git diff` |

### optional parameters

| parameter           | description                                       |
| ------------------- | ------------------------------------------------- |
| `-r`, `--recursive` | iterate over directories in `PATH(s)` recursively |
| `-h`, `--help`      | display this help and exit                        |
| `-v`, `--version`   | output version information and exit               |
