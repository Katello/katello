extends "katello/api/v2/errata/show"

node :applicable_hosts do |erratum|
  erratum.hosts_available.where("#{::Host.table_name}.id" => @hosts).
  select(["#{::Host.table_name}.id", "#{::Host.table_name}.name"]).
  collect { |host| {:name => host.name, :id => host.id} }
end
