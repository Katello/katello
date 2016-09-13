object @resource

attributes :id, :uuid, :name, :version, :release, :arch, :epoch, :summary
attributes :filename, :sourcerpm, :checksum
attributes :nvrea, :nvra

node(:hosts_available_count) { |m| m.hosts_available(params[:organization_id]).count }
node(:hosts_applicable_count) { |m| m.hosts_applicable(params[:organization_id]).count }
