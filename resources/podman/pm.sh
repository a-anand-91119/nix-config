# Manage the default Podman machine. Safe to call repeatedly from Makefiles.
machine="podman-machine-default"

usage() {
  echo "usage: pm up|down|rootful|rootless|status" >&2
  exit 2
}

exists() {
  podman machine inspect "$machine" >/dev/null 2>&1
}

state() {
  podman machine inspect --format '{{.State}}' "$machine"
}

up() {
  if ! exists; then
    podman machine init "$machine"
  fi
  if [ "$(state)" != "running" ]; then
    podman machine start "$machine"
  fi
}

down() {
  if exists && [ "$(state)" = "running" ]; then
    podman machine stop "$machine"
  fi
}

set_mode() {
  if ! exists; then
    podman machine init "$machine"
  fi
  down
  podman machine set "$1" "$machine"
  podman machine start "$machine"
}

status() {
  if ! exists; then
    echo "machine: not created (run: pm up)"
    return
  fi
  echo "machine: $(state)"
  if [ "$(podman machine inspect --format '{{.Rootful}}' "$machine")" = "true" ]; then
    echo "mode:    rootful"
  else
    echo "mode:    rootless"
  fi
  echo "socket:  $(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}' "$machine")"
  echo "DOCKER_HOST: ${DOCKER_HOST:-unset}"
  if [ "$(state)" = "running" ] && podman info >/dev/null 2>&1; then
    echo "api:     reachable"
  else
    echo "api:     unreachable"
  fi
}

case "${1:-}" in
  up) up ;;
  down) down ;;
  rootful) set_mode --rootful ;;
  rootless) set_mode --rootful=false ;;
  status) status ;;
  *) usage ;;
esac
