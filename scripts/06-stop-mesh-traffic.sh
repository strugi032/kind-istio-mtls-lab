#!/usr/bin/env bash
set -euo pipefail

kubectl delete -n lab-mesh -f manifests/mesh-traffic-generator.yaml --ignore-not-found=true
