child :subscription_facet => :subscription_facet_attributes do
  extends 'katello/api/v2/subscription_facet/base'
end

node :content_host_id do |host|
  host.content_host.try(:id)
end

attributes :subscription_status, :subscription_status_label, :subscription_global_status,
           :if => @object.get_status(Katello::SubscriptionStatus).relevant?
