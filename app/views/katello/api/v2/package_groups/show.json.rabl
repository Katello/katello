object @resource

extends "katello/api/v2/package_groups/base"
extends "katello/api/v2/package_groups/backend", :object => Katello::Pulp::PackageGroup.new(@resource.uuid)
