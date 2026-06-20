#!/usr/bin/env bash
set -euo pipefail

kubectl apply -n lab-mesh -f manifests/mesh-traffic-generator.yaml
kubectl rollout status deployment/mesh-traffic-generator -n lab-mesh

echo "Mesh traffic generator is running in lab-mesh."
echo "Check logs with:"
echo "  kubectl logs -n lab-mesh deploy/mesh-traffic-generator -c mesh-traffic-generator -f"
