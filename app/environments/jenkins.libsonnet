
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    jenkins +: {
      storageClassName: "nfs",
      namespace: "devops-tools",
      storageSize: "5Gi",
      replicas: 1,
    },
    jenkinsAgent +: {
      replicas: 2,
    },
  }
}
