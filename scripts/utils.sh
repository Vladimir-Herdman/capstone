#!/usr/bin/env bash

get_base_path() {
    local p
    p="$(pwd)"
    p="${p%%capstone*}capstone"
    printf "%s" "$p"
}

get_mtime() {
    local filepath="$1"
    eval "$(stat -s "$filepath")" #Exposes st_mtime (modified time) as variable in script.
    printf "%s" "$st_mtime"
}
