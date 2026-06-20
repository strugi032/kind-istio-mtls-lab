#!/usr/bin/env bash
set -euo pipefail

ASSUME_YES=0

if [[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]]; then
  ASSUME_YES=1
fi

if [[ "${ASSUME_YES}" -ne 1 ]]; then
  echo "This will delete the kind cluster 'istio-mtls-lab' and all lab namespaces/workloads."
  read -r -p "Continue? Type 'yes' to delete: " CONFIRMATION

  if [[ "${CONFIRMATION}" != "yes" ]]; then
    echo "Cleanup cancelled."
    exit 0
  fi
fi

kind delete cluster --name istio-mtls-lab
