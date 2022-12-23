
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    atlantis_deploy +: {
      atlantis_user: "belas80",
      repo_allowlist: "github.com/belas80/devops-diplom-netology",
      atlantis_url: "http://51.250.9.6:4141",
      repo_config_json: '{"repos":[{"allow_custom_workflows":true,"allowed_overrides":["workflow","apply_requirements","delete_source_branch_on_merge"],"id":"github.com/belas80/devops-diplom-netology"}]}',
      yandex_key_file: "~/.terraform-key/key.json"
},
  }
}
