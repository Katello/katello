extends "katello/api/v2/errata/show"

if @compatibility_mode
  node :applicable_hosts do |erratum|
    erratum.hosts_available.where("#{::Host.table_name}.id" => @hosts).
    select(["#{::Host.table_name}.id", "#{::Host.table_name}.name"]).
    collect { |host| {:name => host.name, :id => host.id} }
  end
end

node(:affected_hosts_count) { |erratum| erratum.hosts_available(params[:organization_id]).where("#{::Host.table_name}.id" => @hosts).count }
