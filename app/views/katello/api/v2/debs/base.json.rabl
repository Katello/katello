object @resource

attributes :id
attributes :name
attributes :version
attributes :architecture
attributes :filename
attributes :checksum
attributes :description
attributes :nav
attributes :nva
attributes :pulp_id
attributes :pulp_id => :uuid
attributes :section
attributes :maintainer
attributes :homepage
attributes :installed_size

node(:hosts_available_count) { |m| m.hosts_available(params[:organization_id]).count }
node(:hosts_applicable_count) { |m| m.hosts_applicable(params[:organization_id]).count }
