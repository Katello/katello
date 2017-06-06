object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends 'katello/api/v2/%s/base' % controller_name

  node :comparison do |content|
    content.comparison
  end
end
