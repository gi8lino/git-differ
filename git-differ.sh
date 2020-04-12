#!/bin/sh

VERSION="v1.0.3"

help() {
    printf "%s\n"  \
           "Usage: git-differ.sh [-s|--skip]" \
           "                     [-a|--all]" \
           "                     [-m|--maxdepth LEVELS]" \
           "                     [-e|--exclude \"DIRECTORY [DIRECTORY] ...\"]"\
           "                     PATH [PATH ...] " \
           "" \
           "Perform a 'git diff --stat' in 'PATH' , or in multiple 'PATHS'." \
           "" \
           "All parameters starting with '--' will be pass to the 'git diff' command and" \
           "the default parameter '--stat' will be removed." \
           "" \
           "positional arguments:" \
           "[PATH ...]                      path or multiple paths to perform a 'git diff'" \
           "" \
           "parameters:" \
           "-s, --skip                      do not show repositories without diff" \
           "-a, --all                       descend over all directories in [PATH ...]" \
           "-m, --maxdepth [LEVELS]         descend at most levels (a non-negative integer) of " \
           "                                directories below [PATH ...]" \
           "                                if set, it ignores '-a', '--all'" \
           "-e, --exclude [DIRECTORY ...]   do not descend into this directory(s)" \
           "                                list of strings, separated by a space and" \
           "                                surrounded by quotes (case sensitive)" \
           "-h, --help                      display this help and exit" \
           "-v, --version                   output version information and exit" \
           "" \
           "created by gi8lino (2020)" \
           "https://github.com/gi8lino/git-differ" \
           ""
    exit 0
}

walk() {
    local _current_dir="${1%/}"  # remove ending slash if set
    local _diff_params="$2"
    local _depth="$3"
    local _recursive="$4"

    for exclude in $EXCLUDES; do [ -z "${_current_dir##*$exclude*}" ] && return; done

    [ ! -z "$DEPTH" ] && \
        [ $_depth -gt $DEPTH ] && \
        return

    if [ -d "${_current_dir}/.git/" ]; then
        git --git-dir="${_current_dir}/.git" --work-tree="${_current_dir}/" diff --quiet; no_changes=$?

        if [ "$no_changes" = 0 ]; then
            [ ! -n "$SKIP" ] && \
                printf "\033[0;35m$_current_dir\033[0m \033[0;32mOK\033[0m\n"
        else
            printf "\033[0;35m$_current_dir\033[0m \033[0;31mNOK\033[0m\n"
            git --git-dir="${_current_dir}/.git" --work-tree="${_current_dir}/" diff "$_diff_params"
        fi
    fi

    [ ! -z "$_recursive" ] || [ ! -z "$DEPTH" ] && \
        for entry in "$_current_dir"/*; do [ -d "${entry}" ] && walk "${entry}" "$_diff_params" "$(($_depth+1))" "$_recursive"; done
}

while [ $# -gt 0 ];do
    key="$1"
    key="${key#"${key%%[![:space:]]*}"}"  # remove leading whitespace
    case $key in
        -a|--all)
        RECURSIVE=True
        shift
        ;;
        -m|--maxdepth)
        DEPTH="$2"
        [ -z "$DEPTH" ] || [ -z "${DEPTH##*[!0-9]*}" ] && \
            printf "\033[0;31mERROR: if you set '%s' it must be followd a number!\033[0m\n" $key && \
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
            printf "\033[0;31mERROR: if you set '%s' it must be followd by minimum one directory!\033[0m\n" $key && \
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
        elif [ ! "${key##\-\-}" ]; then
            DIFF_PARAMS="$DIFF_PARAMS $key"
        else
            printf "\033[0;31mERROR: unknown parameter '$key'\033[0m\n"
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

[ ! -z "$DEPTH" ] && [ ! -z "$RECURSIVE" ] && \
    unset DEPTH

printf "use git diff parameter '\033[0;35m%s\033[0m'\n" "$DIFF_PARAMS"

for dir in ${PATHS}; do
    walk "${dir}" "$DIFF_PARAMS" 0 "$RECURSIVE"
done
