#!/usr/bin/env bash

docker compose up -d --build
docker compose exec capstone bash
