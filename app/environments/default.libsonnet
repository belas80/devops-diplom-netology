
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    myapp +: {
//      indexData: 'hello default\n',
      image: "belas80/myapp:1.0.0",
      replicas: 2,
    },
  }
}
