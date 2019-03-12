object @resource

attributes :id, :pulp_id, :name, :version, :release, :arch, :epoch, :summary, :modular
attributes :filename, :sourcerpm, :checksum
attributes :nvrea, :nvra
attributes :pulp_id => :uuid

node(:hosts_available_count) { |m| m.hosts_available(params[:organization_id]).count }
node(:hosts_applicable_count) { |m| m.hosts_applicable(params[:organization_id]).count }
