attribute :organization_id
child :organization => :organization do |_r|
  attribute :name
  attribute :label
  attribute :id
end
