object false

extends "katello/api/v2/common/index"
extends 'katello/api/v2/alternate_content_sources/permissions'

# Enabled ACS types. Deb is included only when the Pulp deb plugin is enabled.
node :content_types do
  ::Katello::AlternateContentSource.allowed_content_types
end

child @collection[:results] => :results do
  extends "katello/api/v2/alternate_content_sources/base"
end
