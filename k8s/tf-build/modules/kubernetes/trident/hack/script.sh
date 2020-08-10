#!/bin/bash

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
  input=$(jq -r '.')
  echo "DEBUG: input: ${input}" 1>&2
  for query_value in $(echo "${input}" | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]'); do
    export ${query_value}
  done
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
parse_input
install_trident
create_backend
create_storageclass
produce_output