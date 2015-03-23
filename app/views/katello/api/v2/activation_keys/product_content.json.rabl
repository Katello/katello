object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  child :product => :product do
    attributes :id, :name
  end

  child :content => :content do
    attributes :id, :name, :label
  end

  node :override do |pc|
    pc.content_override(@activation_key)
  end
end
