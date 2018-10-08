#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function destroy_cluster {
  $SCRIPT_DIR/scripts/destroy_cluster.sh
}

$SCRIPT_DIR/scripts/setup_cluster.sh
trap destroy_cluster EXIT

go get -u k8s.io/test-infra/kubetest

cd $KUBERNETES_DIR
export KUBERNETES_CONFORMANCE_TEST=y
kubetest --provider=skeleton \
  --test --test_args="--ginkgo.focus=\[Conformance\]" \
  --extract=$KUBETEST_VERSION \
  --dump=$(pwd)/_artifacts | tee $KUBERNETES_DIR/e2e.log


