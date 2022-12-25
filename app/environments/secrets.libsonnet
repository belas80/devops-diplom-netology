
// this file has the param overrides for the default environment
local base = import './base.libsonnet';
//local key = importstr '../.keys/tf-key-json';

base {
  components +: {
    secrets +: {
      namespace: 'default',
      tf_access_key: std.base64(importstr '../.keys/tf_access_key'),
      tf_secret_key: std.base64(importstr '../.keys/tf_secret_key'),
      github_token: std.base64(importstr '../.keys/token'),
      github_webhook: std.base64(importstr '../.keys/webhook-secret'),
//      tf-key: (importstr '../.keys/tf-key-json'),
//      ssh-key: importstr ('../.keys/ssh-key-pub');
    },
  }
}
