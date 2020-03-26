attributes :id, :key, :created, :updated, :lastRefreshed, :virt_who

node :upstreamConsumer do |owner|
  partial('katello/api/v2/organizations/upstream_consumer', object: OpenStruct.new(owner.upstreamConsumer)) if owner.upstreamConsumer
end
