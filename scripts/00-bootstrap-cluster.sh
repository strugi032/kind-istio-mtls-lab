#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="istio-mtls-lab"
KIND_VERSION="v0.27.0"
NODE_IMAGE="kindest/node:v1.32.2@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f"

if [[ "$(kind version)" != *"${KIND_VERSION}"* ]]; then
  echo "ERROR: This lab requires kind ${KIND_VERSION}." >&2
  exit 1
fi

kind create cluster --name "${CLUSTER_NAME}" --image "${NODE_IMAGE}"
