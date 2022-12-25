
// this file has the param overrides for the default environment
local base = import './base.libsonnet';
local ip_nodes = importstr '../config/ip_nodes.txt';

base {
  components +: {
    atlantis +: {
      atlantis_user: "belas80",
      repo_allowlist: "github.com/belas80/devops-diplom-netology",
      atlantis_url: "http://"+ip_nodes+":4141",
      repo_config_json: '{"repos":[{"allow_custom_workflows":true,"allowed_overrides":["workflow","apply_requirements","delete_source_branch_on_merge"],"id":"github.com/belas80/devops-diplom-netology"}]}',
    },
  }
}
