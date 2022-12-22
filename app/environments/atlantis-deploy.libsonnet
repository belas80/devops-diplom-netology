
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    atlantis_deploy +: {
      atlantis_user: "belas80",
      repo_allowlist: "github.com/belas80/devops-diplom-netology",
      atlantis_url: "http://51.250.69.170:4141",
//      tf_access_key: import '../tf_access_key',
//      tf_secret_key: import '../tf_secret_key',
      repo_config_json: '{"repos":[{"allow_custom_workflows":true,"allowed_overrides":["workflow","apply_requirements","delete_source_branch_on_merge"],"id":"github.com/belas80/devops-diplom-netology"}]}',
    },
  }
}
