object @resource

extends "katello/api/v2/subscriptions/base"

attributes :arch
attributes :description
attributes :support_type

node :provided_products, :if => lambda { |sub| sub && !sub.products.blank? } do |subscription|
  subscription.products.map do |product|
    {id: product[:id], name: product[:name]}
  end
end

node :systems do |subscription|
  subscription.hosts.map do |host|
    facts = host.facts
    {
      uuid: host.subscription_facet.try(:uuid),
      host_id: host.id,
      name: host.name,
      environment: { id: host.content_facet.try(:lifecycle_environment).try(:id),
                     name: host.content_facet.try(:lifecycle_environment).try(:name) },
      content_view: { id: host.content_facet.try(:content_view).try(:id),
                      name: host.content_facet.try(:content_view).try(:name) },
      created: host.subscription_facet.try(:registered_at),
      checkin_time: host.subscription_facet.try(:last_checkin),
      entitlement_status: host.subscription_status,
      service_level: host.subscription_facet.try(:service_level),
      autoheal: host.subscription_facet.try(:autoheal),
      facts: {
        dmi: {
          memory: {
            size: facts['dmi::memory::size']
          }
        },
        memory: {
          memtotal: facts['memory::memtotal']
        },
        cpu: {
          'cpu_socket(s)' => facts['cpu::cpu_socket(s)'],
          'core(s)_per_socket' => facts['cpu::core(s)_per_socket']
        },
        virt: {
          is_guest: facts['virt::is_guest']
        }
      }
    }
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
