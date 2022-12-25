local p = import '../params.libsonnet';
local params = p.components.secrets;

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
}
