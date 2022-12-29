local p = import '../params.libsonnet';
local params = p.components.jenkins;

[
  {
    "apiVersion": "rbac.authorization.k8s.io/v1",
    "kind": "ClusterRole",
    "metadata": {
      "name": "jenkins-admin"
    },
    "rules": [
      {
        "apiGroups": [
          ""
        ],
        "resources": [
          "*"
        ],
        "verbs": [
          "*"
        ]
      }
    ]
  },
  {
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
      "name": "jenkins-admin",
    }
  },
  {
    "apiVersion": "rbac.authorization.k8s.io/v1",
    "kind": "ClusterRoleBinding",
    "metadata": {
      "name": "jenkins-admin"
    },
    "roleRef": {
      "apiGroup": "rbac.authorization.k8s.io",
      "kind": "ClusterRole",
      "name": "jenkins-admin"
    },
    "subjects": [
      {
        "kind": "ServiceAccount",
        "name": "jenkins-admin",
        "namespace": "devops-tools"
      }
    ]
  },
  {
    "apiVersion": "v1",
    "kind": "PersistentVolumeClaim",
    "metadata": {
      "name": "jenkins-pv-claim",
    },
    "spec": {
      "storageClassName": params.storageClassName,
      "accessModes": [
        "ReadWriteOnce"
      ],
      "resources": {
        "requests": {
          "storage": params.storageSize
        }
      }
    }
  },
  {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "name": "jenkins",
    },
    "spec": {
      "replicas": params.replicas,
      "selector": {
        "matchLabels": {
          "app": "jenkins-server"
        }
      },
      "template": {
        "metadata": {
          "labels": {
            "app": "jenkins-server"
          }
        },
        "spec": {
          "securityContext": {
            "fsGroup": 1000,
            "runAsUser": 1000
          },
          "serviceAccountName": "jenkins-admin",
          "containers": [
            {
              "name": "jenkins",
              "image": "jenkins/jenkins:lts",
              "resources": {
                "limits": {
                  "memory": "2Gi",
                  "cpu": "1000m"
                },
                "requests": {
                  "memory": "500Mi",
                  "cpu": "500m"
                }
              },
              "ports": [
                {
                  "name": "httpport",
                  "containerPort": 8080
                },
                {
                  "name": "jnlpport",
                  "containerPort": 50000
                }
              ],
              "livenessProbe": {
                "httpGet": {
                  "path": "/login",
                  "port": 8080
                },
                "initialDelaySeconds": 90,
                "periodSeconds": 10,
                "timeoutSeconds": 5,
                "failureThreshold": 5
              },
              "readinessProbe": {
                "httpGet": {
                  "path": "/login",
                  "port": 8080
                },
                "initialDelaySeconds": 60,
                "periodSeconds": 10,
                "timeoutSeconds": 5,
                "failureThreshold": 3
              },
              "volumeMounts": [
                {
                  "name": "jenkins-data",
                  "mountPath": "/var/jenkins_home"
                }
              ]
            }
          ],
          "volumes": [
            {
              "name": "jenkins-data",
              "persistentVolumeClaim": {
                "claimName": "jenkins-pv-claim"
              }
            }
          ]
        }
      }
    }
  },
  {
    "apiVersion": "v1",
    "kind": "Service",
    "metadata": {
      "name": "jenkins-service",
      "annotations": {
        "prometheus.io/scrape": "true",
        "prometheus.io/path": "/",
        "prometheus.io/port": "8080"
      }
    },
    "spec": {
      "selector": {
        "app": "jenkins-server"
      },
      "type": "NodePort",
      "ports": [
        {
          "port": 8080,
          "targetPort": 8080,
          "nodePort": 32000
        }
      ]
    }
  }
]