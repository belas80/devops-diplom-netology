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
                  "name": "AWS_ACCESS_KEY_ID",
                  "valueFrom": {
                    "secretKeyRef": {
                      "key": "tf_access_key",
                      "name": "atlantis-secrets"
                    }
                  }
                },
                {
                  "name": "AWS_SECRET_ACCESS_KEY",
                  "valueFrom": {
                    "secretKeyRef": {
                      "key": "tf_secret_key",
                      "name": "atlantis-secrets"
                    }
                  }
                },
                {
                  "name": "ATLANTIS_REPO_ALLOWLIST",
                  "value": params.repo_allowlist
                },
                {
                  "name": "ATLANTIS_ATLANTIS_URL",
                  "value": params.atlantis_url
                },
                {
                  "name": "ATLANTIS_GH_USER",
                  "value": params.atlantis_user
                },
                {
                  "name": "ATLANTIS_GH_TOKEN",
                  "valueFrom": {
                    "secretKeyRef": {
                      "key": "github_token",
                      "name": "atlantis-secrets"
                    }
                  }
                },
                {
                  "name": "ATLANTIS_GH_WEBHOOK_SECRET",
                  "valueFrom": {
                    "secretKeyRef": {
                      "key": "github_webhook",
                      "name": "atlantis-secrets"
                    }
                  }
                },
                {
                  "name": "ATLANTIS_REPO_CONFIG_JSON",
                  "value": params.repo_config_json
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
                },
                {
                  "mountPath": "/home/atlantis/.terraformrc",
                  "name": "tf-config",
                  "readOnly": true,
                  "subPath": ".terraformrc"
                },
                {
                  "mountPath": "/home/atlantis/.ssh/id_rsa.pub",
                  "name": "ssh-key",
                  "readOnly": true,
                  "subPath": "id_rsa.pub"
                },
                {
                  "mountPath": "/home/atlantis/.terraform-key/key.json",
                  "name": "tf-key",
                  "readOnly": true,
                  "subPath": "key.json"
                }
              ]
            }
          ],
          "securityContext": {
            "fsGroup": 1000
          },
          "volumes": [
            {
              "configMap": {
                "name": "tf-provider-config"
              },
              "name": "tf-config"
            },
            {
              "name": "ssh-key",
              "secret": {
                "secretName": "ssh-key"
              }
            },
            {
              "name": "tf-key",
              "secret": {
                "secretName": "tf-key"
              }
            }
          ]
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
