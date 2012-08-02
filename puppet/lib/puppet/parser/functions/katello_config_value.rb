begin
  require '/usr/share/katello/lib/util/puppet.rb'
rescue LoadError
  fail "Katello was not installed on this host - configuration cannot continue"
end

module Puppet::Parser::Functions
  newfunction(:katello_config_value, :type => :rvalue) do |args|
    return Util::Puppet::config_value(args[0])
  end
end
