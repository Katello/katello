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
  if object.latest_dynflow_scan.respond_to?('ended_at') && object.latest_dynflow_scan.ended_at
    time_ago_in_words(Time.parse(object.latest_dynflow_scan.ended_at.to_s))
  end
end
