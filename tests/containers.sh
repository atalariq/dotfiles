#!/usr/bin/env bash
# JavaScript template strings are intentionally literal.
# shellcheck disable=SC2016
# Real-engine acceptance. Own and remove only this disposable project's resources.
set -euo pipefail
root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
work=$(mktemp -d)
export COMPOSE_PROJECT_NAME="dotfiles-test-$$"
owned=false
volumes=(postgres-data redis-data prometheus-data grafana-data)
cleanup() {
  if [[ $owned == true ]]; then
    (cd "$work" && ./services down) >/dev/null 2>&1 || true
    for name in "${volumes[@]}"; do podman volume rm "${COMPOSE_PROJECT_NAME}_${name}" >/dev/null 2>&1 || true; done
  fi
  rm -rf -- "$work"
}
trap cleanup EXIT
for name in "${volumes[@]}"; do
  if podman volume exists "${COMPOSE_PROJECT_NAME}_${name}"; then echo 'Test volume exists; refusing ownership.' >&2; exit 1; fi
done
cp "$root/devshell/bun-with-services/compose.yaml" "$root/devshell/bun-with-services/services" "$work/"
cp -R "$root/devshell/bun-with-services/observability" "$work/"
export POSTGRES_PASSWORD=disposable-test-password GRAFANA_ADMIN_PASSWORD=disposable-test-password
export POSTGRES_PORT=25432 REDIS_PORT=26379 GRAFANA_PORT=23000 PROMETHEUS_PORT=29090
export OTLP_GRPC_PORT=24317 OTLP_HTTP_PORT=24318 COLLECTOR_HEALTH_PORT=23133
owned=true
cd "$work"
./services up all
wait_ready() {
  for ((attempt=0; attempt<120; attempt++)); do
    if podman exec "${COMPOSE_PROJECT_NAME}_postgres_1" pg_isready -U app -d app >/dev/null 2>&1 && \
       podman exec "${COMPOSE_PROJECT_NAME}_redis_1" redis-cli ping >/dev/null 2>&1 && \
       ./services health >/dev/null 2>&1; then return; fi
    sleep 2
  done
  ./services status
  echo 'Timed out waiting for test services.' >&2
  return 1
}
wait_ready
./services health
podman exec "${COMPOSE_PROJECT_NAME}_postgres_1" psql -U app -d app -c "CREATE TABLE acceptance (value text); INSERT INTO acceptance VALUES ('retained');" >/dev/null
podman exec "${COMPOSE_PROJECT_NAME}_redis_1" redis-cli set acceptance retained >/dev/null
bun -e '
const r = await fetch(`http://127.0.0.1:${process.env.OTLP_HTTP_PORT}/v1/metrics`, {
  method: "POST", headers: {"content-type":"application/json"},
  body: JSON.stringify({resourceMetrics:[{scopeMetrics:[{metrics:[{name:"dotfiles_acceptance", gauge:{dataPoints:[{asDouble:42,timeUnixNano:(BigInt(Date.now())*1000000n).toString()}]}}]}]}]})
}); if (!r.ok) throw new Error(`OTLP: ${r.status}`);
const headers = {authorization:`Basic ${btoa(`admin:${process.env.GRAFANA_ADMIN_PASSWORD}`)}`, "content-type":"application/json"};
const folder = await fetch(`http://127.0.0.1:${process.env.GRAFANA_PORT}/api/folders`, {method:"POST", headers, body:JSON.stringify({uid:"acceptance", title:"Acceptance"})});
if (!folder.ok) throw new Error(`Grafana folder: ${folder.status}`);
'
for ((attempt=0; attempt<60; attempt++)); do
  if bun -e 'const r=await fetch(`http://127.0.0.1:${process.env.PROMETHEUS_PORT}/api/v1/query?query=dotfiles_acceptance`); const j=await r.json(); if(j.data.result[0]?.value[1]!=="42") process.exit(1);'; then break; fi
  sleep 2
done
bun -e 'const j=await (await fetch(`http://127.0.0.1:${process.env.PROMETHEUS_PORT}/api/v1/query?query=dotfiles_acceptance`)).json(); if(j.data.result[0]?.value[1]!=="42") throw new Error("OTLP metric did not reach Prometheus");'
./services down
for name in "${volumes[@]}"; do podman volume exists "${COMPOSE_PROJECT_NAME}_${name}"; done
./services up all
wait_ready
test "$(podman exec "${COMPOSE_PROJECT_NAME}_postgres_1" psql -U app -d app -Atc 'SELECT value FROM acceptance;')" = retained
test "$(podman exec "${COMPOSE_PROJECT_NAME}_redis_1" redis-cli get acceptance)" = retained
bun -e '
const headers={authorization:`Basic ${btoa(`admin:${process.env.GRAFANA_ADMIN_PASSWORD}`)}`};
const base=`http://127.0.0.1:${process.env.GRAFANA_PORT}`;
const folder=await fetch(`${base}/api/folders/acceptance`, {headers}); if(!folder.ok) throw new Error("Grafana data was lost");
const ds=await (await fetch(`${base}/api/datasources/uid/prometheus`,{headers})).json(); if(ds.url!=="http://prometheus:9090") throw new Error("Datasource missing");
const j=await (await fetch(`${base}/api/datasources/proxy/uid/prometheus/api/v1/query?query=dotfiles_acceptance`,{headers})).json();
if(j.data.result[0]?.value[1]!=="42") throw new Error("Persisted metric unavailable through Grafana");
'
printf 'Database persistence and OTLP → Prometheus → Grafana passed, including down/up.\n'
