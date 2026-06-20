#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f manifests/namespaces.yaml
kubectl apply -n lab-mesh -f manifests/workloads.yaml

kubectl rollout status deployment/mesh-client -n lab-mesh
kubectl rollout status deployment/httpbin-server -n lab-mesh
kubectl rollout status deployment/nginx-server -n lab-mesh
kubectl rollout status deployment/whoami-server -n lab-mesh
kubectl rollout status deployment/external-client -n lab-external
