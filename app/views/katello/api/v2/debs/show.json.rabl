object @resource

extends "katello/api/v2/debs/base"
extends "katello/api/v2/debs/backend",
  :object => SmartProxy.pulp_primary!.content_service("deb").new(@resource.pulp_id)
