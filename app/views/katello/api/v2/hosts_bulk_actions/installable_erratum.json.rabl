extends "katello/api/v2/errata/show"

node :applicable_hosts do |erratum|
  erratum.hosts_available(params[:organization_id]).where("#{::Host.table_name}.id" => @hosts).
  pluck(:id, :name).
  map { |id, name| {:name => name, :id => id} }
end

node(:affected_hosts_count) { |erratum| erratum.hosts_available(params[:organization_id]).where("#{::Host.table_name}.id" => @hosts).count }
