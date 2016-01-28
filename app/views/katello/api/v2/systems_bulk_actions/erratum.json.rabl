extends "katello/api/v2/errata/show"

node :applicable_consumers do |erratum|
  erratum.hosts_available.where(:host_id => @systems.map(&:host_id)).
  select(["#{Katello::Host::ContentFacet.table_name}.uuid", "#{Host.table_name}.name"]).
  collect { |system| {:name => system.name, :uuid => system.uuid} }
end
