object @resource

extends "katello/api/v2/subscriptions/base"

attributes :arch
attributes :description
attributes :support_type
attributes :roles, :usage
attributes :product_host_count

node :provided_products, :if => lambda { |sub| sub && !sub.products.blank? } do |subscription|
  subscription.products.map do |product|
    {id: product[:id], name: product[:name]}
  end
end
