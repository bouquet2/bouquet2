default:
    just --list

plan:
    cd tofu && \
    tofu init && \
    tofu plan -var-file=nodes.tfvars -var-file=secrets.tfvars -detailed-exitcode

[confirm("Are you sure you want to deploy? This will overwrite ~/.kube/config and ~/.talos/config!")]
deploy:
    cd tofu && \
    tofu init && \
    tofu apply -var-file=nodes.tfvars -var-file=secrets.tfvars -auto-approve && \
    mkdir -p ~/.kube && \
    mkdir -p ~/.talos && \
    tofu output -raw kubeconfig > ~/.kube/config && \
    tofu output -raw talosconfig > ~/.talos/config

delete-ciliumjob:
    cd tofu && \
    talosctl -n rose patch machineconfig -p @cilium-delete-patch.yaml && \
    kubectl delete ClusterRoleBinding cilium-install && \
    kubectl delete ServiceAccount cilium-install -n kube-system && \
    kubectl delete Job cilium-install -n kube-system

[confirm("Are you sure you want to destroy? This will delete all resources!")]
destroy:
    cd tofu && \
    tofu init && \
    tofu destroy -var-file=nodes.tfvars -var-file=secrets.tfvars -auto-approve

[confirm("Are you sure you want to build the image?")]
hcloud-image-build:
    cd packer && \
    packer build -var-file=secrets.hcl hcloud.pkr.hcl

[confirm("Are you sure you want to deploy manifests?")]
deploy-manifests:
    cd manifests && \
    kubectl kustomize --enable-helm | kubectl apply --force-conflicts --server-side -f -

[confirm("Are you sure you want to destroy manifests?")]
destroy-manifests:
    cd manifests && \
    kubectl kustomize --enable-helm | kubectl delete --force-conflicts --server-side -f -
