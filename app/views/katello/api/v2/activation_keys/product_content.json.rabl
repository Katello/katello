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

  node :override do |pc|
    pc.legacy_content_override
  end

  node :overrides do |pc|
    pc.content_overrides.map do |override|
      {:name => override.name, :value => override.computed_value}
    end
  end

  node :enabled_content_override do |pc|
    override = pc.enabled_content_override
    override.computed_value if override
  end

  attributes :enabled
end
