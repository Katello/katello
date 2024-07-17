object @resource

extends "katello/api/v2/subscriptions/base"

attributes :arch
attributes :description
attributes :support_type
attributes :roles, :usage, :addons
attributes :product_host_count

node(:host_count) do |subscription|
  subscription.hosts.count
end

node :provided_products, :if => lambda { |sub| sub && !sub.products.blank? } do |subscription|
  subscription.products.map do |product|
    {id: product[:id], name: product[:name]}
  end
end

node :activation_keys do |subscription|
  subscription.activation_keys.readable.map do |key|
    {
      id: key.id,
      name: key.name,
      release_version: key.release_version,
      service_level: key.service_level,
      environment: {
        id: key.environment.try(:id),
        name: key.environment.try(:name)
      },
      content_view: {
        id: key.content_view.try(:id),
        name: key.content_view.try(:name)
      }
    }
  end
end
