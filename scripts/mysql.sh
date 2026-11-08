#!/usr/bin/env bash

mariadb -h db -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
