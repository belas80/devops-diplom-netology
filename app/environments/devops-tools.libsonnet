
// this file has the param overrides for the default environment
local base = import './base.libsonnet';
local ip_nodes = importstr '../config/ip_nodes.txt';

base {
  components +: {
    all +: {
      namespace: "devops-tools",
    },
    atlantis +: {
      namespace: "devops-tools",
      atlantis_user: "belas80",
      repo_allowlist: "github.com/belas80/devops-diplom-netology",
      atlantis_url: "http://"+ip_nodes+":4141",
      repo_config_json: '{"repos":[{"allow_custom_workflows":true,"allowed_overrides":["workflow","apply_requirements","delete_source_branch_on_merge"],"id":"github.com/belas80/devops-diplom-netology"}]}',
      tf_config: importstr '../config/.terraformrc',
    },
    jenkins +: {
      storageClassName: "nfs",
      storageSize: "5Gi",
      replicas: 1,
    },
    jenkinsAgent +: {
      storageClassName: "nfs",
      storageSize: "5Gi",
      replicas: 1,
    },
    devopsSecters +: {
      aws_access_key: std.base64(importstr '../.keys/aws_access_key'),
      aws_secret_key: std.base64(importstr '../.keys/aws_secret_key'),
      github_token: std.base64(importstr '../.keys/gh_token'),
      github_webhook: std.base64(importstr '../.keys/gh_webhook_secret'),
      tf_json_key: std.base64(importstr '../.keys/key.json'),
      ssh_key: std.base64(importstr '../.keys/id_rsa.pub')
    },
  }
}
