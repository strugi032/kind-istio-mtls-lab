#!/usr/bin/env bash
set -euo pipefail

kubectl apply -n lab-mesh -f manifests/whoami-50-percent-503.yaml

echo "Fault injection enabled for whoami-server."
echo "About 50% of requests to whoami-server should now return HTTP 503."
