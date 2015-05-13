object @resource

@resource ||= @object

node(:id) { |resource| resource.uuid }
attributes :id => :katello_id
attributes :uuid, :name, :description
attributes :location
attributes :content_view, :content_view_id
attributes :distribution
attributes :katello_agent_installed? => :katello_agent_installed
attributes :registered_by

child :environment => :environment do
  extends 'katello/api/v2/environments/show'
end

child :activation_keys => :activation_keys do
  attributes :id, :name, :description
end

# Candlepin attributes
attributes :entitlementStatus
attributes :autoheal
attributes :release, :ipv4_address
attributes :checkin_time, :created
attributes :installedProducts

node :errata_counts do |system|
  partial('katello/api/v2/errata/counts', :object => Katello::RelationPresenter.new(system.installable_errata))
end
