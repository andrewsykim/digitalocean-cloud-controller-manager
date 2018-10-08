#!/bin/bash

function get_kops {
  echo "==> fetching the latest kops codebase"
  if ! kops version > /dev/null; then
    curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
    chmod +x kops-linux-amd64
    sudo mv kops-linux-amd64 /usr/local/bin/kops
  fi
}

function install_kubectl {
  if ! kubectl version --client=true > /dev/null; then
    echo "==> installing kubectl"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
  fi
}

function install_kubetest {
  if ! kubetest --help > /dev/null; then
    go get -u k8s.io/test-infra/kubetest
  fi
}
