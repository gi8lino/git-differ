#!/bin/sh

VERSION="v1.0.1"

ShowHelp() {
    printf "%s\n"  \
           "Usage: git-differ.sh [-r|--recursive] [-d|-depth N] PATH [PATH ...] | [-h|--help] | [-v|--version]" \
           "" \
           "Perform a 'git diff' in 'PATH' , or in multiple 'PATHS'." \
           "" \
           "All parameters starting with '--' will be pass to the 'git diff' command." \
           "Default 'git diff' parameter is '--stat'." \
           "" \
           "positional arguments:" \
           "[PATH ...]                      path or multiple paths to perform a 'git diff'" \
           "" \
           "parameters:" \
           "-r, --recursive                 iterate over directories in PATH(s) recursively" \
           "-d, --depth N                   max depth for recursion" \
           "-e, --exclude [DIRECTORY...]    exclude directory(s) for checking for 'git diff'" \
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
    local _recursive="$3"
    local _depth="$4"

    for exclude in $EXCLUDES; do [ -z "${_current_dir##*$exclude*}" ] && return; done

    [ ! -z "$DEPTH" ] && \
        [ $_depth -gt $DEPTH ] && \
        return

    if [ -d "${_current_dir}/.git/" ]; then
        git --git-dir=$_current_dir/.git --work-tree=$_current_dir/ diff --quiet; nochanges=$?

        printf "\033[0;35m$_current_dir\033[0m "
        if [ "$nochanges" = 0 ]; then
            printf "\033[0;32mOK\033[0m\n"
        else
            printf "\033[0;31mNOK\033[0m\n"
            eval git --git-dir=$_current_dir/.git --work-tree=$_current_dir/ diff "$_diff_params"
        fi
    fi

    _depth=$(($_depth+1))
    [ ! -z "$_recursive" ] && \
        for entry in "$_current_dir"/*; do [ -d "$entry" ] && walk "$entry" "$_diff_params" "$_recursive" "$_depth"; done
}

while [ $# -gt 0 ];do
    key="$1"
    key="${key#"${key%%[![:space:]]*}"}"  # remove leading whitespace
    case $key in
	    -r|--recursive)
	    RECURSIVE=true
	    shift
	    ;;
        -d|--depth)
	    DEPTH="$2"
        [ -z "$DEPTH" ] || [ -z "${DEPTH##*[!0-9]*}" ] && \
            printf "\033[0;31mERROR: if you set '%s' it must be followd a number!\033[0m\n" $key && \
            exit 1
        
	    shift
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
	    ShowHelp
	    ;;
	    *)
        if [ -d "$key" ]; then
            PATHS="$PATHS $key"
        elif [ "${key##\-\-}" ]; then
            DIFF_PARAMS="$DIFF_PARAMS $key"
        else
            printf "\033[0;31mERROR: unknown parameter '$key'\033[0m\n"
        fi
        shift
	    ;;
    esac
done

# check parameters
[ -z "$PATHS" ] && PATHS="*/"  # if no directory was given add current directory
[ -z "$DIFF_PARAMS" ] && DIFF_PARAMS="--stat"  # check if git diff parameter was set

[ ! -z "$DEPTH" ] && [ ! -n "$RECURSIVE" ] && \
    printf "\033[0;31mERROR: you cannot set '--depth' without '--recursive'\033[0m\n" && \
    exit 1

printf "use git diff parameters '%s'\n" "$DIFF_PARAMS"

for dir in $PATHS; do
    walk "$dir" $DIFF_PARAMS $RECURSIVE 0
done
