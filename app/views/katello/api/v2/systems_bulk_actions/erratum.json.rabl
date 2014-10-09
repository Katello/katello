extends "katello/api/v2/errata/show"

node :applicable_consumers do |erratum|
    erratum.systems_available.where(:id => @systems.map(&:id)).
    select(["#{Katello::System.table_name}.uuid", "#{Katello::System.table_name}.name"]).
    collect{|system| {:name => system.name, :uuid => system.uuid}}
end
