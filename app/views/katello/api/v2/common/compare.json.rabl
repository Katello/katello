object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
#  extends 'katello/api/v2/%s/base' % controller_name

  node :item do |content|
    if content.item.class == ::Katello::Rpm
      content.item.nvra
    elsif content.item.class == ::Katello::DockerTag
      content.item.repository.name + "-" + content.item.name
    else
      content.item.name
    end
  end

  node :comparison do |content|
    content.comparison
  end
end
