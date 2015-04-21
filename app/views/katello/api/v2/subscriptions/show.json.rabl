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

attributes :arch, :virt_only, :unmapped_guest
attributes :sockets, :cores, :ram
attributes :instance_multiplier, :stacking_id, :multi_entitlement

node :provided_products, :if => lambda { |sub| sub && !sub.products.blank? } do |subscription|
  subscription.products.map do |product|
    {id: product[:id], name: product[:name]}
  end
end

node :systems, :if => (params[:action] == "show") do |subscription|
  subscription.systems.readable.map do |sys|
    facts = sys.facts
    {
      uuid: sys.uuid,
      name: sys.name,
      environment: { id: sys.environment.id, name: sys.environment.name },
      content_view: { id: sys.content_view.id, name: sys.content_view.name },
      created: sys.created,
      checkin_time: sys.checkin_time,
      entitlement_status: sys.entitlementStatus,
      service_level: sys.serviceLevel,
      autoheal: sys.autoheal,
      facts: {
        memory: {
          memtotal: facts['memory.memtotal']
        },
        cpu: {
          'cpu_socket(s)' => facts['cpu.cpu_socket(s)'],
          'core(s)_per_socket' => facts['cpu.core(s)_per_socket']
        },
        virt: {
          is_guest: facts['virt.is_guest']
        }
      }
    }
  end
end

node :activation_keys, :if => (params[:action] == "show") do |subscription|
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

node :host, :if => lambda { |sub| sub && sub.host } do |subscription|
  {
    id: subscription.host.uuid,
    name: subscription.host.name
  }
end
