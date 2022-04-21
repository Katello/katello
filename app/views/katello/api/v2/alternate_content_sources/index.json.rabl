object false

extends "katello/api/v2/common/index"

child @collection[:results] => :results do
  extends "katello/api/v2/alternate_content_sources/base"
end
