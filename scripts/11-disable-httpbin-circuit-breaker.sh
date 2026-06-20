#!/usr/bin/env bash
set -euo pipefail

kubectl delete -n lab-mesh -f manifests/httpbin-aggressive-circuit-breaker.yaml --ignore-not-found=true

echo "Circuit breaker disabled for httpbin-server."
echo "The load tester is still deployed."
echo "Delete it with:"
echo "  kubectl delete -n lab-mesh -f manifests/load-tester.yaml"
