#!/usr/bin/env bash
set -euo pipefail

CHART_NAMESPACE=${CHART_NAMESPACE:-mayastor}
BIN_DIR=/workspace/bin
PATH="$BIN_DIR:$PATH"

ensure_tools() {
  mkdir -p "$BIN_DIR"
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "[+] Installing kubectl locally into $BIN_DIR"
    KVER=$(curl -sL https://dl.k8s.io/release/stable.txt)
    curl -sL -o "$BIN_DIR/kubectl" "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl"
    chmod +x "$BIN_DIR/kubectl"
  fi
  if ! command -v helm >/dev/null 2>&1; then
    echo "[+] Installing helm locally into $BIN_DIR"
    HELM_VER=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -sL -o /tmp/helm.tar.gz "https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz"
    tar -C /tmp -xzf /tmp/helm.tar.gz
    mv /tmp/linux-amd64/helm "$BIN_DIR/helm"
    chmod +x "$BIN_DIR/helm"
    rm -rf /tmp/linux-amd64 /tmp/helm.tar.gz
  fi
}

ensure_tools

echo "[+] Adding OpenEBS Helm repo"
helm repo add openebs https://openebs.github.io/charts >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1 || true

echo "[+] Installing Mayastor chart into namespace ${CHART_NAMESPACE}"
helm upgrade --install mayastor openebs/mayastor \
  --namespace "${CHART_NAMESPACE}" \
  --create-namespace \
  -f /workspace/k8s/mayastor/values.yaml

echo "[+] Labelling all nodes for Mayastor io-engine scheduling (if required by chart)"
kubectl label nodes --all openebs.io/engine=mayastor-io-engine --overwrite || true

echo "[+] Applying loopback pool DaemonSet (creates one DiskPool per node)"
kubectl apply -f /workspace/k8s/mayastor/loopback-pools.yaml

echo "[+] Applying Mayastor StorageClass"
kubectl apply -f /workspace/k8s/mayastor/storageclass.yaml

echo "[+] Done. Validate with: kubectl -n mayastor get pods; kubectl get diskpool"

