local p = import '../params.libsonnet';
local params = p.components.atlantis;

[
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
  }
]