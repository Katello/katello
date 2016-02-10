child :subscription_facet => :subscription do
  extends 'katello/api/v2/subscription_facet/base'

  node :compliance_reasons do |facet|
    if facet.uuid
      consumer = Katello::Candlepin::Consumer.new(facet.uuid)
      consumer.compliance_reasons
    end
  end
end

node :content_host_id do |host|
  host.content_host.try(:id)
end
