object false

extends "katello/api/v2/common/metadata"

node(:composite) { Katello::ContentView.readable.in_organization(Organization.current).composite.count }
node(:component) { Katello::ContentView.readable.in_organization(Organization.current).non_composite.count }

child @collection[:results] => :results do
  extends "katello/api/v2/content_views/base"
end
