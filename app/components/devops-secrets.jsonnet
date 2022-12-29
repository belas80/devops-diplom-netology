local p = import '../params.libsonnet';
local params = p.components.all;
local devopsSec = p.components.devopsSecters;

[
  {
    "apiVersion": "v1",
    "data": {
      "aws_access_key": devopsSec.aws_access_key,
      "aws_secret_key": devopsSec.aws_secret_key,
      "github_token": devopsSec.github_token,
      "github_webhook": devopsSec.github_webhook,
      "tf_json_key": devopsSec.tf_json_key,
      "ssh_key": devopsSec.ssh_key
    },
    "kind": "Secret",
    "metadata": {
      "name": "devops-secrets",
      "namespace": params.namespace
    },
    "type": "Opaque"
  }
]