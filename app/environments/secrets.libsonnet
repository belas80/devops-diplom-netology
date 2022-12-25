
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    secrets +: {
      namespace: 'default',
      aws_access_key: std.base64(importstr '../.keys/aws_access_key'),
      aws_secret_key: std.base64(importstr '../.keys/aws_secret_key'),
      github_token: std.base64(importstr '../.keys/gh_token'),
      github_webhook: std.base64(importstr '../.keys/gh_webhook_secret'),
      tf_json_key: std.base64(importstr '../.keys/key.json'),
      ssh_key: std.base64(importstr '../.keys/id_rsa.pub')
    },
  }
}
