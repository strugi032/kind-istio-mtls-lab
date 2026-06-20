#!/usr/bin/env bash
set -euo pipefail

REQUESTS=60

run_load() {
  kubectl exec -n lab-mesh deploy/load-tester -c load-tester -- \
    fortio load -c 4 -qps 0 -n "${REQUESTS}" http://httpbin-server:8000/get 2>&1
}

code_count() {
  local code="$1"
  awk -v code="${code}" '$1 == "Code" && $2 == code && $3 == ":" {print $4}' | tail -n 1
}

kubectl delete -n lab-mesh -f manifests/httpbin-aggressive-circuit-breaker.yaml --ignore-not-found=true >/dev/null
sleep 5
baseline="$(run_load)"
printf '%s\n' "${baseline}"
baseline_200="$(printf '%s\n' "${baseline}" | code_count 200)"
baseline_503="$(printf '%s\n' "${baseline}" | code_count 503)"

if [[ "${baseline_200:-0}" -ne "${REQUESTS}" || "${baseline_503:-0}" -ne 0 ]]; then
  echo "FAIL: baseline expected ${REQUESTS} HTTP 200 responses and no 503 responses." >&2
  exit 1
fi
echo "PASS: baseline returned ${REQUESTS}/${REQUESTS} HTTP 200 responses"

kubectl apply -n lab-mesh -f manifests/httpbin-aggressive-circuit-breaker.yaml >/dev/null
sleep 5
result="$(run_load)"
printf '%s\n' "${result}"
result_200="$(printf '%s\n' "${result}" | code_count 200)"
result_503="$(printf '%s\n' "${result}" | code_count 503)"

if [[ "${result_200:-0}" -le 0 || "${result_503:-0}" -le 0 || $((result_200 + result_503)) -ne "${REQUESTS}" ]]; then
  echo "FAIL: circuit-breaker run expected both HTTP 200 and HTTP 503 responses." >&2
  exit 1
fi
echo "PASS: circuit breaker returned ${result_200} HTTP 200 and ${result_503} HTTP 503 responses"
