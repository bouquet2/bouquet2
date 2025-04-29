default:
    just --list

[confirm("Are you sure you want to deploy? This will overwrite ~/.kube/config")]
deploy:
    cd tofu && \
    tofu apply -var-file=nodes.tfvars -var-file=secrets.tfvars -auto-approve && \
    tofu output -raw kubeconfig > ~/.kube/config

[confirm("Are you sure you want to destroy? This will delete all resources!")]
destroy:
    cd tofu && \
    tofu destroy -var-file=nodes.tfvars -var-file=secrets.tfvars -auto-approve

[confirm("Are you sure you want to build the image?")]
hcloud-image-build:
    cd packer && \
    packer build -var-file=secrets.hcl hcloud.pkr.hcl

[confirm("Are you sure you want to deploy manifests?")]
deploy-manifests:
    cd manifests && \
    kubectl kustomize --enable-helm | kubectl apply -f -

