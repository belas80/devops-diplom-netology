
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    atlantis_deploy +: {
      atlantis_user: "belas80",
      repo_allowlist: "github.com/belas80/devops-diplom-netology/*",
    },
  }
}
