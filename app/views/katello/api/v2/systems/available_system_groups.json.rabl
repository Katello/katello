extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends("katello/api/v2/system_groups/show")
end
