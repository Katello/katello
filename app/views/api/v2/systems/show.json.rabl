object @resource

@resource ||= @object

attributes :id, :uuid, :location, :servicelevel, :content_view
attributes :environment, :description
attributes :name, :release, :ipv4_address
attributes :distribution_name, :kernel, :arch, :memory
attributes :compliance, :serviceLevel, :autoheal
attributes :href, :system_template_id
attributes :created, :checkin_time
attributes :installedProducts
# TODO needs investigation whether it is safe to remove
attributes :facts
attributes :type

node :releaseVer do |sys|
  sys.releaseVer.is_a?(Hash) ? sys.releaseVer[:releaseVer] : sys.releaseVer
end

child :system_groups => :systemGroups do
  attributes :id, :name
end

child :custom_info => :customInfo do
  attributes :id, :keyname, :value
end

child :environment => :environment do
  extends 'api/v2/environments/show'
end

child :activation_keys => :activation_keys do
  attributes :id, :name, :description
end

if @resource.respond_to?(:guest) || @resource.respond_to?(:host)
  if @resource.guest
    node :host do |system|
      system.host.attributes
    end
  else
    node :guests do |system|
      system.guests.map(&:attributes)
    end
  end
end

extends 'api/v2/common/timestamps'
extends 'api/v2/common/readonly'
