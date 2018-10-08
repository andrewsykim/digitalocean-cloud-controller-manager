#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/scripts/utils.sh

function destroy_cluster {
  $SCRIPT_DIR/scripts/destroy_cluster.sh
}

$SCRIPT_DIR/scripts/setup_cluster.sh
trap destroy_cluster EXIT

install_kubetest

export KUBERNETES_CONFORMANCE_TEST=y
kubetest --provider=skeleton \
  --test --test_args="--ginkgo.focus=\[Conformance\]" \
  --extract=$KUBETEST_VERSION \
  --dump=$RESULTS_DIR/_artifacts | tee $RESULTS_DIR/e2e.log

