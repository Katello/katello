object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends 'katello/api/v2/repositories/base'
  node :comparison do |result|
    result.comparison_repositories
  end
end
