attributes :id, :uuid, :last_checkin, :service_level, :release_version, :autoheal, :registered_at, :registered_through, :purpose_role, :purpose_usage, :purpose_addons

child :user => :user do
  attributes :id, :login
end
