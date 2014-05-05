object @resource

@resource ||= @object

attributes :id, :uuid
attributes :name, :description
attributes :location
attributes :content_view, :content_view_id

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

child :system_groups => :systemGroups do
  attributes :id, :name, :description, :max_systems, :total_systems
end

child :custom_info => :customInfo do
  attributes :id, :keyname, :value
end

child :environment => :environment do
  extends 'katello/api/v2/environments/show'
end

child :activation_keys => :activation_keys do
  attributes :id, :name, :description
end

# Candlepin attributes
attributes :entitlementStatus
attributes :autoheal
attributes :href, :release, :ipv4_address
attributes :checkin_time, :created
attributes :installedProducts

attributes :serviceLevel => :service_level

node :release_ver do |sys|
  sys.releaseVer.is_a?(Hash) ? sys.releaseVer[:releaseVer] : sys.releaseVer
end

# Requires another API call to fetch from Candlepin
if params[:fields] == "full"
  attributes :type
  attributes :compliance
  attributes :facts

  if @resource.respond_to?(:guest) || @resource.respond_to?(:host)
    if @resource.guest
      node :host do |system|
        system.host.attributes if system.host
      end
    else
      node :guests do |system|
        system.guests.map(&:attributes)
      end
    end
  end
end

node :permissions do |activation_key|
  {
    :editable => true
  }
end
