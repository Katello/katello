object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  child :product => :product do
    attributes :id, :name
  end

  child :content => :content do
    attributes :id, :name, :label
  end

  attributes :enabled_override, :enabled
end
