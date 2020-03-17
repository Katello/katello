attributes :id, :key, :created, :updated, :lastRefreshed, :virt_who

node :upstreamConsumer, if: lambda { |o| o.upstreamConsumer } do |owner_details|
  partial('katello/api/v2/organizations/upstream_consumer', object: OpenStruct.new(owner_details.upstreamConsumer))
end
