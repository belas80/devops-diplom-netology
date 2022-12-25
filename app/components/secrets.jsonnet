local p = import '../params.libsonnet';
local params = p.components.secrets;

{
  "apiVersion": "v1",
  "data": {
    "tf_access_key": params.tf_access_key,
    "tf_secret_key": params.tf_secret_key,
    "github_token": params.github_token,
    "github_webhook": params.github_webhook,
//    "tf-key": params.tf-key
  },
  "kind": "Secret",
  "metadata": {
    "name": "atlantis-secrets",
    "namespace": params.namespace
  },
  "type": "Opaque"
}
