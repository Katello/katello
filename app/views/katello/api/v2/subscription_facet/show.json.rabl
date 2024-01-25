child :subscription_facet => :subscription_facet_attributes do |_facet|
  extends 'katello/api/v2/subscription_facet/base'

  node :compliance_reasons do |sub_facet|
    sub_facet.compliance_reasons.pluck(:reason)
  end

  child :hypervisor_host => :virtual_host do
    attributes :id, :name
    node :display_name do |host|
      host.to_label
    end
  end

  child :virtual_guests => :virtual_guests do
    attributes :id, :name
  end

  child :installed_products => :installed_products do
    attributes :name => :productName, :cp_product_id => :productId
    attributes :arch, :version
  end

  child :activation_keys => :activation_keys do
    attributes :id, :name
  end

  attributes :host_type, :dmi_uuid
end
