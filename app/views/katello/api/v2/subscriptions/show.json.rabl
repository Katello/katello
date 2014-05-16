# TODO: Bug #4005: allow Rabl.render(object, 'something/show') to work
#       http://projects.theforeman.org/issues/4005#change-12796
#       Ideally, as_json would be replaced w/ rabl output which would solve this need
#       for duplication and sync between rabl and elasticsearch indexing.
#       See also models/katello/glue/elasticsearch/pool.rb

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

node :provided_products, :if => lambda { |sub| sub && !sub.provided_products.blank? } do |subscription|
  subscription.provided_products.map { |product| {id: product[:id], name: product[:productName]} }
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

node :distributors, :if => (params[:action] == "show") do |subscription|
  current_organization = subscription.organization
  subscription.distributors.readable(current_organization).map { |dist| {id: dist.id, name: dist.name} }
end

node :host, :if => lambda { |sub| sub && sub.host } do |subscription|
  {id: subscription.host.id, name: subscription.host.name}
end
