#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

if [[ "${MODE}" != "permissive" && "${MODE}" != "strict" ]]; then
  echo "Usage: $0 <permissive|strict>" >&2
  exit 1
fi

mesh_request() {
  kubectl exec -n lab-mesh deploy/mesh-client -c mesh-client -- \
    curl -fsS --max-time 5 http://httpbin-server:8000/get >/dev/null
}

external_request() {
  kubectl exec -n lab-external deploy/external-client -c external-client -- \
    curl -fsS --max-time 5 http://httpbin-server.lab-mesh:8000/get \
    >"${TMP_DIR}/external.out" 2>"${TMP_DIR}/external.err"
}

apply_mode() {
  local mode="$1"
  local actual

  kubectl apply -n lab-mesh -f "manifests/peerauthentication-${mode}.yaml" >/dev/null
  actual="$(kubectl get peerauthentication lab-mesh-mtls -n lab-mesh -o jsonpath='{.spec.mtls.mode}')"

  if [[ "${actual}" != "${mode^^}" ]]; then
    echo "FAIL: expected PeerAuthentication ${mode^^}, found ${actual}" >&2
    exit 1
  fi
}

wait_for_external_success() {
  for _ in {1..15}; do
    if external_request; then
      return 0
    fi
    sleep 2
  done

  echo "FAIL: external request never succeeded in PERMISSIVE mode." >&2
  sed 's/^/  /' "${TMP_DIR}/external.err" >&2
  exit 1
}

kubectl wait -n lab-mesh --for=condition=available --timeout=60s deployment/httpbin-server deployment/mesh-client >/dev/null
kubectl wait -n lab-external --for=condition=available --timeout=60s deployment/external-client >/dev/null

# Prove DNS, routing, and the external client work before testing STRICT rejection.
apply_mode permissive
wait_for_external_success
echo "PASS: external plaintext request succeeds in PERMISSIVE mode"

if [[ "${MODE}" == "permissive" ]]; then
  mesh_request
  echo "PASS: in-mesh request succeeds in PERMISSIVE mode"
  exit 0
fi

apply_mode strict

# A plaintext request rejected by the STRICT sidecar exits curl with code 56.
for _ in {1..15}; do
  if external_request; then
    sleep 2
    continue
  else
    status=$?
  fi

  if grep -Eq 'curl: \(56\)|exit code 56' "${TMP_DIR}/external.err"; then
    mesh_request
    echo "PASS: external plaintext is rejected and in-mesh mTLS succeeds in STRICT mode"
    exit 0
  fi

  echo "FAIL: external request failed for an unexpected reason (curl exit ${status})." >&2
  sed 's/^/  /' "${TMP_DIR}/external.err" >&2
  exit 1
done

echo "FAIL: external plaintext still succeeds in STRICT mode." >&2
exit 1
