object @subscription

attributes :cp_id => :id

# When attached candlepin entitlements are returned (eg. for subscriptions attached
# to systems), the 'id' is the entitlement id. This field is for referencing the
# original subscription.
attributes :subscription_id

attributes :description

extends 'katello/api/v2/common/org_reference'

attributes :product_name
attributes :start_date, :end_date
attributes :available, :quantity, :consumed, :amount
attributes :account_number, :contract_number
attributes :support_type, :support_level
attributes :product_id

attributes :arch, :virt_only
attributes :sockets, :cores, :ram
attributes :instance_multiplier, :stacking_id, :multi_entitlement

node :provided_products, :if => lambda { |sub| sub && !sub.products.blank? } do |subscription|
  subscription.products.map do |product|
    {id: product[:id], name: product[:name]}
  end
end

node :systems, :if => (params[:action] == "show") do |subscription|
  current_organization = subscription.organization
  subscription.systems.readable.map { |sys| {id: sys.id, name: sys.name} }
end

# TODO: what should replace this since activerecord relation is gone?
#       http://projects.theforeman.org/issues/4255
# node :activation_keys, :if => (params[:action] == "show") do |subscription|
#   current_organization = subscription.organization
#   subscription.activation_keys.readable(current_organization).map { |key| {id: key.id, name: key.name} }
# end

node :host, :if => lambda { |sub| sub && sub.host } do |subscription|
  {id: subscription.host.id, name: subscription.host.name}
end
