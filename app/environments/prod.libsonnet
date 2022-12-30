
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    myapp +: {
      image: "belas80/myapp:1.0.0",
      replicas: 3,
    },
  }
}
