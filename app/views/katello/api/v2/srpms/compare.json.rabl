object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends 'katello/api/v2/srpms/base'
  node :comparison do |result|
    result.comparison
  end
end
