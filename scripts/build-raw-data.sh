#!/usr/bin/env bash

EXPECTED_FILES=(
    'part_aa Gary Varney'
    'part_ab Gary Varney'
    'part_ac Gary Varney'
    'part_ad Gary Varney'
    'part_ae Gary Varney'
    'ONU_dataonly_masked.tar Gary Varney.gz'
    'Network Info for students Garay Varney.zip'
    'PurePerformanceData Garay Varney.zip'
    'vm_perf_1yr_prod Gary Varney.zip'
)

get_base_path() {
    local p
    p="$(pwd)"
    p="${p%%capstone*}capstone"
    printf "%s" "$p"
}

missing_files() {
    local zippath="$1"
    local -n outarr="$2"
    local f fp

    for f in "${EXPECTED_FILES[@]}"; do
        fp="$zippath/$f"
        if [[ ! -e "$fp" ]]; then
            outarr+=("$fp")
        fi
    done

    if [[ "${#outarr[@]}" != "0" ]]; then return 1; fi
    return 0
}

main() {
    local basepath zippath f
    basepath="$(get_base_path)"
    zippath="$basepath/data/zips"

    local -a missing=()
    if ! missing_files "$zippath" missing; then
        printf "ERROR: %d missing files\n" "${#missing[@]}"
        for f in "${missing[@]}"; do
            printf "\t- %s\n" "${f##*/}"
        done
        return 1
    fi

    if [[ ! -e "$zippath/ONU_dated_masked.tar.gz" ]]; then
        echo "Creating zips/ONU_dated_masked.tar.gz from part_a*"
        cat "$zippath"/part_a* > "$zippath/ONU_dated_masked.tar.gz"
        echo "done"
    fi

    local dirname
    for f in "$zippath"/*.zip; do
        dirname="${f%%.zip*}"
        dirname="${dirname//zips/raw}"
        if [[ -d "$dirname" ]]; then
            continue
        fi
        mkdir "$dirname"
        printf "Unzipping %s\n" "zips${f##*zips}"
        unzip -q "$f" -d "$dirname"
        echo "done"
    done

    for f in "$zippath"/*.tar*.gz; do
        dirname="${f%%.tar*}"
        dirname="${dirname//zips/raw}"
        if [[ -d "$dirname" ]]; then
            continue
        fi
        mkdir "$dirname"
        printf "ungzipping and expanding tar %s\n" "zips${f##*zips}"
        tar -xf "$f" -C "$dirname"
        echo "done"
    done

    return 0
}

main
