## OpenEBS Mayastor with loop-backed DiskPools across all nodes (incl. control-plane)

### What this provides
- Replicated block storage via Mayastor, similar to Longhorn
- Replicas can run on all nodes, including control-planes, by adding tolerations
- No separate disk partition needed: uses a loop-backed file as a block device on each node

### Files
- `values.yaml`: Helm values enabling tolerations for control-plane nodes
- `loopback-pools.yaml`: DaemonSet that creates a sparse file + loop device (`/dev/loop10`) on each node and creates a `DiskPool` CR
- `storageclass.yaml`: StorageClass `mayastor-repl3` using provisioner `io.openebs.csi-mayastor` with `repl: 3`
- `smoke-test.yaml`: Simple PVC + Pod to validate storage
- `/workspace/scripts/install-mayastor.sh`: Installer that fetches local `kubectl`/`helm` if absent, installs chart, labels nodes, applies resources

### Requirements
- A working Kubernetes cluster and kubeconfig context
- Sufficient free space on each node for the sparse file (default 100Gi)
  - Adjust by setting env `POOL_SIZE` on the `mayastor-loopback` DaemonSet if desired

### Install
```bash
bash /workspace/scripts/install-mayastor.sh
```
This will:
- Install `kubectl` and `helm` locally into `/workspace/bin` if missing
- Install the Mayastor Helm chart into namespace `mayastor`
- Label all nodes for io-engine scheduling (if the chart uses that label)
- Deploy the loopback DaemonSet to create `/dev/loop10` on each node
- Create a `DiskPool` per node that points to `/dev/loop10`
- Create `StorageClass` `mayastor-repl3`

### Test
```bash
kubectl apply -f /workspace/k8s/mayastor/smoke-test.yaml
kubectl -n mayastor-test get pvc,pod
kubectl get diskpool
kubectl -n mayastor get pods
```
When the `fio` Pod is running, verify the volume is mounted at `/data` and data is written.

### Notes
- Mayastor typically requires full block devices for pools; a loop device provides a block device abstraction backed by a file. This is convenient for labs but not recommended for production.
- To change the replica count, edit `storageclass.yaml` and set `parameters.repl` to your desired number.
- If your chart key names differ for tolerations or components, run:
```bash
helm show values openebs/mayastor | less
```
and update `values.yaml` accordingly.

### Cleanup
```bash
kubectl delete -f /workspace/k8s/mayastor/smoke-test.yaml || true
kubectl delete -f /workspace/k8s/mayastor/loopback-pools.yaml || true
helm -n mayastor uninstall mayastor || true
kubectl delete ns mayastor mayastor-test || true
```

