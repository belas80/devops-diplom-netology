
// this file has the param overrides for the default environment
local base = import './base.libsonnet';
//local key = importstr ('/users/a.belyaev/.terraform-key/key.json');

base {
  components +: {
    secrets +: {
      namespace: 'default',
      tf_access_key: std.base64(importstr '../tf_access_key'),
      tf_secret_key: std.base64(importstr '../tf_secret_key'),
      github_token: std.base64(importstr '../token'),
      github_webhook: std.base64(importstr '../webhook-secret'),
//      tf-key: key,
    },
  }
}
