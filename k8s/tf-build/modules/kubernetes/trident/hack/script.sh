#!/bin/bash
# ssh_key_generator - designed to work with the Terraform External Data Source provider
#   https://www.terraform.io/docs/providers/external/data_source.html
#  by Irving Popovetsky <irving@popovetsky.com> 
#
#  this script takes the 3 customer_* arguments as JSON formatted stdin
#  produces public_key & private_key (contents) and the private_key_file (path) as JSON formatted stdout
#  DEBUG statements may be safely uncommented as they output to stderr

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function check_deps() {
   test -f $(which tridentctl) || error_exit "tridentctl command not detected in path, please install it"
  test -f $(which kubectl) || error_exit "kubectl command not detected in path, please install it"
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
}

function parse_input() {
  # jq reads from stdin so we don't have to set up any inputs, but let's validate the outputs
  eval "$(jq -r '@sh "export NAMESPACE=\(.namespace) BACKEND=\(.backend) STORAGECLASSES=\(.storageclasses)"')"
  if [[ -z "${NAMESPACE}" ]]; then export NAMESPACE=none; fi
  if [[ -z "${BACKEND}" ]]; then export BACKEND=none; fi
  if [[ -z "${STORAGECLASSES}" ]]; then export STORAGECLASSES=none; fi
}

function install_trident() {
    tridentctl install -n ${NAMESPACE}
}

function create_backend() {
    tridentctl -n ${NAMESPACE} create backend -f ${BACKEND}
}

function create_storageclass() {
    cat ${STORAGECLASSES} | kubectl apply -f -
}

function produce_output() {
  result="OK"

  jq -n \
    --arg result "$result" \
    '{"result":$result}'
}

# main()
check_deps
# echo "DEBUG: received: $INPUT" 1>&2
parse_input
install_trident
create_backend
create_storageclass
produce_output