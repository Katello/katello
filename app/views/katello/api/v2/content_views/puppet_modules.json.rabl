object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do |_results|
  extends 'katello/api/v2/puppet_modules/show'
end
