object @resource

@resource ||= @object

attributes :id, :uuid
attributes :name, :description
attributes :location
attributes :content_view, :content_view_id

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
attributes :servicelevel, :autoheal
attributes :href, :release, :ipv4_address
attributes :checkin_time, :created
attributes :installedProducts



node :releaseVer do |sys|
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
