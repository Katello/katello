child :subscription_facet => :subscription do |facet|
  extends 'katello/api/v2/subscription_facet/base'
  consumer = Katello::Candlepin::Consumer.new(facet.uuid)

  node :compliance_reasons do
    consumer.compliance_reasons
  end

  node :virtual_host do |_subscription_facet|
    if host = consumer.virtual_host
      {:name => host.name, :id => host.id}
    end
  end

  node :virtual_guests do |_subscription_facet|
    consumer.virtual_guests.map do |guest|
      {:name => guest.name, :id => guest.id}
    end
  end

  node :installed_products do
    consumer.installed_products
  end

  child :activation_keys => :activation_keys do
    attributes :id, :name
  end
end

node :content_host_id do |host|
  host.content_host.try(:id)
end
