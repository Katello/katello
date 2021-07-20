object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends "katello/api/v2/generic_content_units/base"
end
