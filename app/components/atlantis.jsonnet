local p = import '../params.libsonnet';
local params = p.components.atlantis;
// local prefix = 'atlantis-';

[
  {
    "apiVersion": "v1",
    "data": {
      "aws_access_key": params.aws_access_key,
      "aws_secret_key": params.aws_secret_key,
      "github_token": params.github_token,
      "github_webhook": params.github_webhook,
      "tf_json_key": params.tf_json_key,
      "ssh_key": params.ssh_key
    },
    "kind": "Secret",
    "metadata": {
      "name": "atlantis-secrets",
      "namespace": params.namespace
    },
    "type": "Opaque"
  },
  {
      "apiVersion": "v1",
      "data": {
          ".terraformrc": params.tf_config
      },
      "kind": "ConfigMap",
      "metadata": {
          "name": "tf-provider-config",
          "namespace": params.namespace,
      }
  },
  {
    "apiVersion": "apps/v1",
    "kind": "StatefulSet",
    "metadata": {
      "name": "atlantis",
      "namespace": params.namespace
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
                      "key": "aws_access_key",
                      "name": "atlantis-secrets"
                    }
                  }
                },
                {
                  "name": "AWS_SECRET_ACCESS_KEY",
                  "valueFrom": {
                    "secretKeyRef": {
                      "key": "aws_secret_key",
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
                  "mountPath": "/home/atlantis/.ssh",
                  "name": "ssh-key",
                  "readOnly": true,
                },
                {
                  "mountPath": "/home/atlantis/.terraform-key",
                  "name": "tf-key",
                  "readOnly": true,
                }
              ]
            }
          ],
          "securityContext": {
            "runAsUser": 100,
            "runAsGroup": 1000,
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
                "secretName": "atlantis-secrets",
                "items": [
                  {
                    "key": "ssh_key",
                    "path": "id_rsa.pub"
                  }
                ]
              }
            },
            {
              "name": "tf-key",
              "secret": {
                "secretName": "atlantis-secrets",
                "items": [
                  {
                    "key": "tf_json_key",
                    "path": "key.json"
                  }
                ]
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
      "name": "atlantis",
      "namespace": params.namespace
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
