object @resource

extends "katello/api/v2/content_view_versions/base"

child :puppet_modules => :puppet_modules do
  attributes :id
  attributes :name
  attributes :author
  attributes :version
end
