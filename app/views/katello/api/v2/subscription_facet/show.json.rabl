child :subscription_facet => :subscription do
  extends 'katello/api/v2/subscription_facet/base'

  node :compliance_reasons do |facet|
    if facet.uuid
      consumer = Katello::Candlepin::Consumer.new(facet.uuid)
      consumer.compliance_reasons
    end
  end

  node :installed_products do |facet|
    consumer = Katello::Candlepin::Consumer.new(facet[:uuid])
    consumer.installed_products
  end

  child :activation_keys => :activation_keys do
    attributes :id, :name
  end
end

node :content_host_id do |host|
  host.content_host.try(:id)
end

if @resource.respond_to?(:virtual_guest) || @resource.respond_to?(:virtual_host)
  if @resource.virtual_guest
    node :virtual_host do |system|
      system.virtual_host.attributes if system.virtual_host
    end
  else
    node :virtual_guests do |system|
      system.virtual_guests.map(&:attributes)
    end
  end
end
