#!/usr/bin/env bash
set -euo pipefail

kubectl delete -n lab-mesh -f manifests/whoami-50-percent-503.yaml --ignore-not-found=true

echo "Fault injection disabled for whoami-server."
