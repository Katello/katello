object @resource

extends "katello/api/v2/packages/base"
extends "katello/api/v2/packages/backend", :object => Katello::Pulp::Rpm.new(@resource.uuid)
