module Puppet::Parser::Functions
  # without setting pulp url using fqdn urls to pulp repo in TDL
  # manifests are not usable
  newfunction(:katello_pulp_url, :type => :rvalue) do |args|
    host = lookupvar("::fqdn")
    host = "localhost" if host.nil? || host.empty?
    "https://#{host}/pulp/api/v2/".downcase
  end
end
