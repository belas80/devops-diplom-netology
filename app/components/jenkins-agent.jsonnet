local p = import '../params.libsonnet';
local params = p.components.jenkinsAgent;

[
  {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "name": "jenkins-agent",
      "labels": {
        "jenkins": "jenkins-agent"
      }
    },
    "spec": {
      "replicas": params.replicas,
      "selector": {
        "matchLabels": {
          "jenkins": "jenkins-agent"
        }
      },
      "template": {
        "metadata": {
          "labels": {
            "jenkins": "jenkins-agent"
          }
        },
        "spec": {
          "containers": [
            {
              "name": "jenkins-agent",
              "image": "belas80/jenkins-agent",
              "imagePullPolicy": "Always",
              "ports": [
                {
                  "containerPort": 22
                }
              ],
              "env": [
                {
                  "name": "JENKINS_AGENT_SSH_PUBKEY",
                  "valueFrom": {
                    "secretKeyRef": {
                      "key": "ssh_key",
                      "name": "devops-secrets"
                    }
                  }
                },
                {
                  "name": "DOCKER_HOST",
                  "value": "tcp://localhost:2376"
                },
                {
                  "name": "DOCKER_TLS_VERIFY",
                  "value": "1"
                },
                {
                  "name": "DOCKER_CERT_PATH",
                  "value": "/certs/client"
                }
              ],
              "volumeMounts": [
                {
                  "mountPath": "/home/jenkins/agent",
                  "name": "jenkins-agent-data"
                },
                {
                  "name": "some-docker-certs-client",
                  "mountPath": "/certs/client",
                  "readOnly": true
                }
              ]
            },
            {
              "name": "dind",
              "image": "docker:dind",
              "securityContext": {
                "privileged": true
              },
              "env": [
                {
                  "name": "DOCKER_TLS_CERTDIR",
                  "value": "/certs"
                }
              ],
              "volumeMounts": [
                {
                  "name": "dind-storage",
                  "mountPath": "/var/lib/docker"
                },
                {
                  "name": "some-docker-certs-client",
                  "mountPath": "/certs/client"
                }
              ]
            }
          ],
          "volumes": [
            {
              "name": "jenkins-agent-data",
              "persistentVolumeClaim": {
                "claimName": "jenkins-agent-pv-claim"
              }
            },
            {
              "name": "dind-storage",
              "emptyDir": {}
            },
            {
              "name": "some-docker-certs-client",
              "emptyDir": {}
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
      "name": "jenkins-agent",
    },
    "spec": {
      "ports": [
        {
          "port": 2222,
          "name": "http",
          "targetPort": 22
        }
      ],
      "selector": {
        "jenkins": "jenkins-agent"
      },
      "type": "ClusterIP"
    }
  },
  {
    "apiVersion": "v1",
    "kind": "PersistentVolumeClaim",
    "metadata": {
      "labels": {
        "jenkins": "jenkins-agent"
      },
      "name": "jenkins-agent-pv-claim",
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
      "storageClassName": params.storageClassName
    }
  }
]