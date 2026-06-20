#!/usr/bin/env bash
set -euo pipefail

if ! command -v istioctl >/dev/null 2>&1; then
  echo "ERROR: istioctl is not installed or not on PATH." >&2
  exit 1
fi

ISTIO_DIR="${ISTIO_DIR:-}"

if [[ -z "${ISTIO_DIR}" ]]; then
  ISTIOCTL_BIN="$(command -v istioctl)"
  ISTIO_DIR="$(cd "$(dirname "${ISTIOCTL_BIN}")/.." && pwd)"
fi

ADDONS_DIR="${ISTIO_DIR}/samples/addons"

if [[ -d "${ADDONS_DIR}" ]]; then
  kubectl apply -f "${ADDONS_DIR}/prometheus.yaml"
  kubectl apply -f "${ADDONS_DIR}/grafana.yaml"
  kubectl apply -f "${ADDONS_DIR}/kiali.yaml"
else
  ISTIO_VERSION="$(istioctl version --remote=false 2>/dev/null | awk '/client version:/ {print $3; exit}')"

  if [[ -z "${ISTIO_VERSION}" ]]; then
    echo "ERROR: Could not detect istioctl client version." >&2
    echo "Set ISTIO_DIR to an extracted Istio release directory, for example:" >&2
    echo "  ISTIO_DIR=/path/to/istio ./scripts/02-install-observability.sh" >&2
    exit 1
  fi

  echo "Could not find local Istio addons directory: ${ADDONS_DIR}"
  echo "Falling back to Istio ${ISTIO_VERSION} sample addon manifests from GitHub."
  echo "This requires network access to raw.githubusercontent.com."

  kubectl apply -f "https://raw.githubusercontent.com/istio/istio/${ISTIO_VERSION}/samples/addons/prometheus.yaml"
  kubectl apply -f "https://raw.githubusercontent.com/istio/istio/${ISTIO_VERSION}/samples/addons/grafana.yaml"
  kubectl apply -f "https://raw.githubusercontent.com/istio/istio/${ISTIO_VERSION}/samples/addons/kiali.yaml"
fi

kubectl rollout status deployment/prometheus -n istio-system
kubectl rollout status deployment/grafana -n istio-system
kubectl rollout status deployment/kiali -n istio-system
