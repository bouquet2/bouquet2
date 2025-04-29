default:
    just --list

[confirm("Are you sure you want to deploy? This will overwrite ~/.kube/config")]
deploy:
    cd tofu && \
    tofu apply -var-file=nodes.tfvars -var-file=secrets.tfvars -auto-approve && \ # Apply infrastructure changes
    tofu output -raw kubeconfig > ~/.kube/config # Update kubeconfig

[confirm("Are you sure you want to deploy manifests?")]
deploy-manifests:
    cd manifests && \
    kubectl kustomize --enable-helm | kubectl apply -f - # Apply manifests

