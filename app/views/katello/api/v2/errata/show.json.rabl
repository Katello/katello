object @resource

attributes :id, :pulp_id, :title, :errata_id
attributes :issued, :updated, :version, :status, :release
attributes :severity, :description, :solution, :summary, :reboot_suggested
attributes :_href
attributes :pulp_id => :uuid

child :cves => :cves do
  attributes :cve_id, :href
end

child :bugzillas => :bugs do
  attributes :bug_id, :href
end

attributes :title => :name
attributes :errata_type => :type

unless @disable_counts
  node(:hosts_available_count) { |m| m.hosts_available_count(params[:organization_id]) }
  node(:hosts_applicable_count) { |m| m.hosts_applicable_count(params[:organization_id]) }
end

node :packages do |e|
  e.package_nvreas
end

node :module_streams do |e|
  e.module_streams
end
