attributes :id, :uuid, :last_checkin, :service_level, :release_version, :autoheal, :registered_at, :registered_through, :purpose_role, :purpose_usage, :hypervisor, :convert2rhel_through_foreman

child :user => :user do
  attributes :id, :login
end

node :purpose_addons do |sub|
  sub.purpose_addons.pluck(:name)
end
