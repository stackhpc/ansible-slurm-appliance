#!/usr/bin/env bash

#####
# Small script that can be used to attach to the infra container of a pod
#
# Useful in a systemd service that starts a pod in order to track the execution
#
# Accepts a single argument which is the name of the pod whose infra container we should attach to
#####

set -e

echo "[INFO] Finding infra container for pod '$1'"
INFRA_CONTAINER_ID="$(podman pod inspect --format '{{.InfraContainerID}}' "$1")"

echo "[INFO] Attaching to infra container '${INFRA_CONTAINER_ID}'"
exec podman container attach --no-stdin ${INFRA_CONTAINER_ID}
