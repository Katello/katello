object @subscription

attributes :id, :entitlementId, :poolId, :cp_id
attributes :product_name, :poolName
attributes :sla, :support_level, :contractNumber, :contract_number
attributes :available, :quantity, :consumed, :accountNumber
attributes :endDate, :startDate, :start_date, :end_date
attributes :account_number, :support_type, :arch, :virt_only
attributes :sockets, :cores, :ram, :multi_entitlement
attributes :instance_multiplier, :stacking_id
attributes :attributes, :productAttributes
attributes :productId => :product_id

node :provided_products, :if => lambda { |sub| sub && !sub.provided_products.blank? } do |subscription|
  subscription.provided_products.map { |product| {id: product[:id], name: product[:productName]} }
end

node :systems, :if => (params[:action] == "show") do |subscription|
  current_organization = subscription.organization
  subscription.systems.readable(current_organization).map { |sys| {id: sys.id, name: sys.name} }
end

node :activation_keys, :if => (params[:action] == "show") do |subscription|
  current_organization = subscription.organization
  subscription.activation_keys.readable(current_organization).map { |key| {id: key.id, name: key.name} }
end

node :distributors, :if => (params[:action] == "show") do |subscription|
  current_organization = subscription.organization
  subscription.distributors.readable(current_organization).map { |dist| {id: dist.id, name: dist.name} }
end

node :host, :if => lambda { |sub| sub && sub.host } do |subscription|
  {id: subscription.host.id, name: subscription.host.name}
end
