object @resource

extends "katello/api/v2/packages/base"
extends "katello/api/v2/packages/backend",
  :object => SmartProxy.pulp_primary!.content_service("rpm").new(@resource.pulp_id)
