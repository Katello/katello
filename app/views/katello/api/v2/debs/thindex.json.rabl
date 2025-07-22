object false

extends "katello/api/v2/common/metadata"
child @collection[:results] => :results do |_results|
  attributes :name, :id
end
