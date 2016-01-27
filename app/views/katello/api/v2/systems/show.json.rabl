object @resource

@resource ||= @object

extends "katello/api/v2/systems/base"

child :products => :products do |_product|
  attributes :id, :name
end
attributes :content_overrides

child :foreman_host => :host do
  attributes :id, :name
  attributes :host_status => :status
  attributes :last_report

  child :environment => :puppet_environment do
    attributes :id, :name
  end
  child :operatingsystem do
    attributes :id, :name, :description
  end
  child :model do
    attributes :id, :name
  end
  child :hostgroup do
    attributes :id, :name
  end
end

child @resource.foreman_host.host_collections => :hostCollections do
  attributes :id, :name, :description, :max_hosts, :unlimited_hosts, :total_hosts
end

attributes :serviceLevel => :service_level

node :release_ver do |sys|
  sys.releaseVer.is_a?(Hash) ? sys.releaseVer[:releaseVer] : sys.releaseVer
end

# Requires another API call to fetch from Candlepin
if params[:fields] == "full"
  attributes :system_type => :type
  attributes :compliance
  attributes :facts

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
end

node :permissions do |_activation_key|
  {
    :editable => true
  }
end
