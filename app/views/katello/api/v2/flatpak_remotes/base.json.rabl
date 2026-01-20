extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/flatpak_remotes/permissions'

attributes :name
attributes :url, :description, :username, :seeded, :registry_url

node :upstream_password_exists do |fr|
  fr.token.present?
end

child :latest_dynflow_scan => :last_scan do |_object|
  attributes :id, :username, :started_at, :ended_at, :state, :result, :progress
end

node :last_scan_words do |object|
  scan = object.latest_dynflow_scan
  if scan&.ended_at
    time_ago_in_words(scan.ended_at)
  end
end
