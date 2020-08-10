#!/usr/bin/env bash
IMAGE_NAME=sgryczan/tf-trident
IMAGE_TAG=latest
DELIVERABLES=${DELIVERABLES_DIR:-"${PWD}/deliverables"}

OPERATION=$1

if [ "$OPERATION" == "destroy" ]; then
  docker run -it --rm -v "$TFVARS":/terraform/vsphere-rancher/rancher.tfvars \
      -v "$DELIVERABLES":/terraform/vsphere-rancher/deliverables \
      ${IMAGE_NAME}:"$IMAGE_TAG" "$OPERATION" -auto-approve \
      -var-file=/terraform/vsphere-rancher/rancher.tfvars \
      -target=module.nodes
else
  docker run -it --rm -v "$TFVARS":/terraform/terraform.tfvars \
      -v "$DELIVERABLES":/terraform/deliverables \
      ${IMAGE_NAME}:"$IMAGE_TAG" "$OPERATION" -auto-approve \
      -var-file=/terraform/vsphere-rancher/rancher.tfvars
fi
