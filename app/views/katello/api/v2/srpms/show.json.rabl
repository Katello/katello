object @resource

extends "katello/api/v2/srpms/base"
extends "katello/api/v2/srpms/backend",
  :object => SmartProxy.pulp_master!.content_service("srpm").new(@resource.pulp_id)
