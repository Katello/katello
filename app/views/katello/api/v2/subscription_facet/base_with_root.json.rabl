child :subscription_facet => :subscription do
  extends 'katello/api/v2/subscription_facet/base'
end

node :content_host_id do |host|
  host.content_host.id
end
