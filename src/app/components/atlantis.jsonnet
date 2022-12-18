local p = import '../params.libsonnet';
local params = p.components.atlantis;
// local prefix = 'atlantis-';

[
  {
    "apiVersion": "apps/v1",
    "kind": "StatefulSet",
    "metadata": {
      "name": "atlantis"
    },
    "spec": {
      "replicas": 1,
      "selector": {
        "matchLabels": {
          "app": "atlantis"
        }
      },
      "serviceName": "atlantis",
      "template": {
        "metadata": {
          "labels": {
            "app": "atlantis"
          }
        },
        "spec": {
          "containers": [
            {
              "env": [
                {
                  "name": "ATLANTIS_REPO_ALLOWLIST",
                  "value": params.repo_allowlist
                },
                {
                  "name": "ATLANTIS_GH_USER",
                  "value": params.atlantis_user
                },
                {
                  "name": "ATLANTIS_GH_TOKEN",
                  "valueFrom": {
                    "secretKeyRef": {
                      "key": "token",
                      "name": "atlantis-vcs"
                    }
                  }
                },
                {
                  "name": "ATLANTIS_GH_WEBHOOK_SECRET",
                  "valueFrom": {
                    "secretKeyRef": {
                      "key": "webhook-secret",
                      "name": "atlantis-vcs"
                    }
                  }
                },
                {
                  "name": "ATLANTIS_DATA_DIR",
                  "value": "/atlantis"
                },
                {
                  "name": "ATLANTIS_PORT",
                  "value": "4141"
                }
              ],
              "image": "ghcr.io/runatlantis/atlantis:v0.21.0",
              "livenessProbe": {
                "httpGet": {
                  "path": "/healthz",
                  "port": 4141,
                  "scheme": "HTTP"
                },
                "periodSeconds": 60
              },
              "name": "atlantis",
              "ports": [
                {
                  "containerPort": 4141,
                  "name": "atlantis"
                }
              ],
              "readinessProbe": {
                "httpGet": {
                  "path": "/healthz",
                  "port": 4141,
                  "scheme": "HTTP"
                },
                "periodSeconds": 60
              },
              "resources": {
                "limits": {
                  "cpu": "100m",
                  "memory": "256Mi"
                },
                "requests": {
                  "cpu": "100m",
                  "memory": "256Mi"
                }
              },
              "volumeMounts": [
                {
                  "mountPath": "/atlantis",
                  "name": "atlantis-data"
                }
              ]
            }
          ],
          "securityContext": {
            "fsGroup": 1000
          }
        }
      },
      "updateStrategy": {
        "rollingUpdate": {
          "partition": 0
        },
        "type": "RollingUpdate"
      },
      "volumeClaimTemplates": [
        {
          "metadata": {
            "name": "atlantis-data"
          },
          "spec": {
            "accessModes": [
              "ReadWriteOnce"
            ],
            "resources": {
              "requests": {
                "storage": "5Gi"
              }
            },
            "storageClassName": "nfs"
          }
        }
      ]
    }
  },
  {
    "apiVersion": "v1",
    "kind": "Service",
    "metadata": {
      "name": "atlantis"
    },
    "spec": {
      "ports": [
        {
          "name": "atlantis",
          "nodePort": 30001,
          "port": 80,
          "targetPort": 4141
        }
      ],
      "selector": {
        "app": "atlantis"
      },
      "type": "NodePort"
    }
  }
]
