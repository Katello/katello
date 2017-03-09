object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  child :product => :product do
    attributes :id, :name
  end

  child :content => :content do
    attributes :id, :name, :label
    attribute :contentUrl => :content_url
  end

  child :overrides => :content_overrides do
    attributes :name
    attribute :computed_value => :value
  end

  node :enabled_content_override do |pc|
    override = pc.enabled_content_override
    override.computed_value if override
  end

  attributes :override, :enabled

  #TODO: deprecate with 6.4
  attributes :override => :enabled_override
end
