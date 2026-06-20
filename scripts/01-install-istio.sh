#!/usr/bin/env bash
set -euo pipefail

if ! command -v istioctl >/dev/null 2>&1; then
  echo "ERROR: istioctl is not installed or not on PATH." >&2
  exit 1
fi

ISTIO_VERSION="1.30.1"
INSTALLED_VERSION="$(istioctl version --remote=false 2>/dev/null | awk '/client version:/ {print $3; exit}')"

if [[ "${INSTALLED_VERSION}" != "${ISTIO_VERSION}" ]]; then
  echo "ERROR: This lab requires istioctl ${ISTIO_VERSION}; found ${INSTALLED_VERSION:-unknown}." >&2
  exit 1
fi

# The demo profile is intentionally used for this local learning lab.
# It is convenient for trying Istio features, but it is not production-ready.
istioctl install --set profile=demo -y
