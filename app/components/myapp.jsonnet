local p = import '../params.libsonnet';
local params = p.components.myapp;
local prefix = 'myapp-';

[
  {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "labels": {
        "app": prefix + "deploy"
      },
      "name": prefix + "deploy"
    },
    "spec": {
      "replicas": params.replicas,
      "selector": {
        "matchLabels": {
          "app": prefix + "deploy"
        }
      },
      "template": {
        "metadata": {
          "labels": {
            "app": prefix + "deploy"
          }
        },
        "spec": {
          "containers": [
            {
              "image": params.image,
              "name": prefix + "main",
              "ports": [
                {
                  "containerPort": 80
                }
              ]
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
      "name": prefix + "service"
    },
    "spec": {
      "ports": [
        {
          "name": "http",
          "nodePort": 30000,
          "port": 80,
          "targetPort": 80
        }
      ],
      "selector": {
        "app": prefix + "deploy"
      },
      "type": "NodePort"
    }
  }
]