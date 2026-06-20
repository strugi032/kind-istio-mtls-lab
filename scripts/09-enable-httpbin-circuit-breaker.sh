#!/usr/bin/env bash
set -euo pipefail

kubectl apply -n lab-mesh -f manifests/load-tester.yaml
kubectl rollout status deployment/load-tester -n lab-mesh

kubectl apply -n lab-mesh -f manifests/httpbin-aggressive-circuit-breaker.yaml

echo "Aggressive circuit breaker enabled for httpbin-server."
echo "Load tester deployed as deploy/load-tester in lab-mesh."
