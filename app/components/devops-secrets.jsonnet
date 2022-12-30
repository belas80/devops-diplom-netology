local p = import '../params.libsonnet';
local params = p.components.devopsSecters;

[
  {
    "apiVersion": "v1",
    "data": {
      "aws_access_key": params.aws_access_key,
      "aws_secret_key": params.aws_secret_key,
      "github_token": params.github_token,
      "github_webhook": params.github_webhook,
      "tf_json_key": params.tf_json_key,
      "kube_cfg": params.kube_cfg,
      "ssh_key": params.ssh_key
    },
    "kind": "Secret",
    "metadata": {
      "name": "devops-secrets",
    },
    "type": "Opaque"
  }
]