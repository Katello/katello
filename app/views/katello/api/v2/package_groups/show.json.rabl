object @resource

extends "katello/api/v2/package_groups/base"
extends "katello/api/v2/package_groups/backend", :object => SmartProxy.pulp_master.pulp3_repository_type_support?('yum') ? Katello::Pulp3::PackageGroup.new(@resource.pulp_id) : Katello::Pulp::PackageGroup.new(@resource.pulp_id)
