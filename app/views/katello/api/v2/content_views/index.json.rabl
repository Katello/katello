object false

extends "katello/api/v2/common/metadata"
extends 'katello/api/v2/content_views/permissions'

child @collection[:results] => :results do
  extends "katello/api/v2/content_views/base"
end
