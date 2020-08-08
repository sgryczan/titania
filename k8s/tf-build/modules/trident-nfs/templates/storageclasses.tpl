apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: solidfire-nfs
parameters:
  backendType: ontap-nas
provisioner: netapp.io/trident
reclaimPolicy: Delete
volumeBindingMode: Immediate