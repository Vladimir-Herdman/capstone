#!/usr/bin/env bash
#I think this only works Mac, that's all I've tested it on. Helps me save some
#time for building docker containers or just starting without needing to
#remember commands.

set -e

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/globals.sh"

projpath="$(get_base_path)/$REPONAME"
build_containers=false

log_stamps() {
    local dockerstamp="$1" composestamp="$2"
    printf "#!/usr/bin/env bash\n\n%s\n%s" "log_dockerfile_mtime=$dockerstamp" "log_compose_mtime=$composestamp" > "$projpath/scripts/.mtime-info"
}

dockerfile_mtime="$(get_mtime "$projpath/Dockerfile")"
compose_mtime="$(get_mtime "$projpath/compose.yaml")"

if [[ -e "$projpath/scripts/.mtime-info" ]]; then
    source "$projpath/scripts/.mtime-info"
    if [[ "$dockerfile_mtime" -gt "$log_dockerfile_mtime" || "$compose_mtime" -gt "$log_compose_mtime" ]]; then
        build_containers=true
    fi
fi
log_stamps "$dockerfile_mtime" "$compose_mtime"

if "$build_containers"; then
    docker compose up -d --build
fi
docker compose exec capstone bash
