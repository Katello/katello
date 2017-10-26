object @resource

attributes :id, :uuid, :title, :errata_id
attributes :issued, :updated, :version, :status, :release
attributes :severity, :description, :solution, :summary, :reboot_suggested
attributes :_href

child :cves => :cves do
  attributes :cve_id, :href
end

attributes :title => :name
attributes :errata_type => :type

node(:hosts_available_count) { |m| m.hosts_available(params[:organization_id]).count }
node(:hosts_applicable_count) { |m| m.hosts_applicable(params[:organization_id]).count }

node :packages do |e|
  e.packages.pluck(:nvrea)
end
