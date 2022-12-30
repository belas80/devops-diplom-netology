
// this file has the param overrides for the default environment
local base = import './base.libsonnet';
local imageTag = std.extVar('myapp_image_tag');

base {
  components +: {
    myapp +: {
//      indexData: 'hello default\n',
      image: "belas80/myapp:"+imageTag,
      replicas: 2,
    },
  }
}
