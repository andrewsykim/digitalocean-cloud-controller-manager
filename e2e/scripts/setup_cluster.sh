#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/utils.sh

if [[ -z $KOPS_CLUSTER_NAME ]]; then
  echo "KOPS_CLUSTER_NAME is required for e2e tests"
  exit 1
fi

SSH_PUBLIC_KEYFILE="${SSH_PUBLIC_KEYFILE:-~/.ssh/id_rsa.pub}"
KOPS_REGION="${KOPS_REGION:-tor1}"

install_kubectl
get_kops

kops create cluster --cloud=digitalocean \
  --name=$KOPS_CLUSTER_NAME \
  --zones=$KOPS_REGION \
  --ssh-public-key=$SSH_PUBLIC_KEYFILE \
  --networking=flannel \
  --yes

echo "==> waiting until kubernetes cluster is ready..."

n=0
until [ $n -ge 300 ]
do
  if [[ $(kubectl get no wc -l) -eq 4 ]]; then
    echo "==> kubernetes cluster is ready"
    exit 0
  fi

  n=$[$n+1]
  sleep 5
done

echo "==> timed out waiting for kubernetes cluster to be ready"
exit 1
