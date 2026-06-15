object false

extends "katello/api/v2/common/index"
extends 'katello/api/v2/content_credentials/permissions'

child @collection[:results] => :results do
  extends "katello/api/v2/content_credentials/show"
end
