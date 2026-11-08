#!/usr/bin/env bash
#For use specifically in the 'capstone' container, not personal environments.

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/globals.sh"

projpath="$(get_base_path)"

case "$1" in
    load)
        mariadb -h db -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$projpath/scripts/sql/vm_perf_1yr_prod/"*sql
        mariadb -h db -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
        ;;
    *)
        mariadb -h db -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
        ;;
esac
