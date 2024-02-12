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
  node(:hosts_available_count) { |m| m.hosts_available(params[:organization_id]).count }
  node(:hosts_applicable_count) { |m| m.hosts_applicable(params[:organization_id]).count }
end

node :packages do |e|
  e.packages.non_module_stream_packages.pluck(:nvrea)
end

node :module_streams do |e|
  e.module_streams
end

child :deb_packages => :deb_packages do
  attributes :name, :version, :release
end
