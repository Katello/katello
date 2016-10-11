attributes :id, :uuid, :last_checkin, :service_level, :release_version, :autoheal, :registered_at, :registered_through

child :user => :user do
  attributes :id, :login
end
