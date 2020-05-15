#!/bin/sh

VERSION="v1.0.5"

REDC='\033[0;31m'
GREENC='\033[0;32m'
PURPLEC='\033[0;35m'
UNDERLINE='\e[4m'
NC='\033[0m' # no color / no format

help() {
    printf \
"Usage: git-differ.sh [-s|--skip]
                     [-r|--recursive]
                     [-m|--maxdepth LEVELS]
                     [-e|--exclude \"DIRECTORY [DIRECTORY] ...\"]
                     [-h|--help]
                     [-v|--version]
                     PATH [PATH ...]

Perform a 'git diff --stat' in one or more (sub)directories.

All parameters starting with '--' will be passed to the 'git diff' command and
the default parameter '--stat' will be removed.

positional arguments:
[PATH ...]                      one or more directories to perform a 'git diff'

parameters:
-s, --skip                      do ${UNDERLINE}not${NC} show repositories without diff
-r, --recursive                 iterate over directories and ${UNDERLINE}all${NC} their
                                subdirectories recursively
-m, --maxdepth [LEVELS]         iterate over directories and their subdirectories until
                                the set [LEVELS] is reached (a non-negative integer).
                                if set, it ignores '-r|--recursive'
-e, --exclude [DIRECTORY ...]   do not descend into this (sub)directories
                                list of strings, separated by a space and
                                surrounded by quotes (case sensitive)
-h, --help                      display this help and exit
-v, --version                   output version information and exit

created by gi8lino (2020)
https://github.com/gi8lino/git-differ
\n"
exit 0                                
}

walk() {
    local _current_dir="${1%/}"  # remove ending slash if set
    local _diff_params="$2"
    local _depth="$3"
    local _recursive="$4"

    for exclude in $EXCLUDES; do [ -z "${_current_dir##*$exclude*}" ] && return; done

    [ -n "$DEPTH" ] && \
        [ $_depth -gt $DEPTH ] && \
        return

    if [ -d "${_current_dir}/.git/" ]; then
        git --git-dir="${_current_dir}/.git" --work-tree="${_current_dir}/" diff --quiet; no_changes=$?

        if [ "$no_changes" = 0 ]; then
            [ ! -n "$SKIP" ] && \
                printf "${PURPLEC}${_current_dir} ${GREENC}OK${NC}\n"
        else
            printf "${PURPLEC}${_current_dir} ${REDC}NOK${NC}\n"
            git --git-dir="${_current_dir}/.git" --work-tree="${_current_dir}/" diff "$_diff_params"
        fi
    fi

    [ -n "$_recursive" ] || [ -n "$DEPTH" ] && \
        for entry in "$_current_dir"/*; do [ -d "${entry}" ] && walk "${entry}" "$_diff_params" "$(($_depth+1))" "$_recursive"; done
}

while [ $# -gt 0 ];do
    key="$1"
    key="${key#"${key%%[![:space:]]*}"}"  # remove leading whitespace
    [ -z "${key}" ] && shift && continue # skip empty strings
    case $key in
        -r|--recursive)
        RECURSIVE=True
        shift
        ;;
        -m|--maxdepth)
        DEPTH="$2"
        [ -z "$DEPTH" ] || [ -z "${DEPTH##*[!0-9]*}" ] && \
            printf "${REDC}ERROR: if you set '%s' it must be followd a number!${NC}\n" $key && \
            exit 1
        shift
        shift
        ;;
        -s|--skip)
        SKIP=True
        shift
        ;;
        -e|--exclude)
        EXCLUDES="$2"
        [ ! -n "$EXCLUDES" ] && \
            printf "${REDC}ERROR: if you set '%s' it must be followd by minimum one directory!${NC}\n" $key && \
            exit 1
        shift
        shift
        ;;
        -v|--version)
        printf "git-differ.sh version: %s\n" "${VERSION}"
        exit 0
        ;;
        -h|--help)
        help
        ;;
        *)
        if [ -d "${key}" ]; then
            PATHS="$PATHS ${key}"
        elif [ "${key##\-\-}" ]; then
            DIFF_PARAMS="$DIFF_PARAMS $key"
        else
            printf "${REDC}ERROR: unknown parameter '$key'${NC}\n"
        fi
        shift
        ;;
    esac
done

# check parameters
[ -z "$PATHS" ] && PATHS="*/"  # if no directory was set take current directory

[ -z "$DIFF_PARAMS" ] && \
    DIFF_PARAMS="--stat" || \
    DIFF_PARAMS=${DIFF_PARAMS#"${DIFF_PARAMS%%[![:space:]]*}"}

[ -n "$DEPTH" ] && [ -n "$RECURSIVE" ] && \
    unset DEPTH

for dir in ${PATHS}; do
    walk "${dir}" "$DIFF_PARAMS" 0 "$RECURSIVE"
done
