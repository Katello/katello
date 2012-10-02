begin
  require '/usr/share/katello/lib/util/puppet.rb'
rescue LoadError
  fail "Katello was not installed on this host - configuration cannot continue"
end

module Puppet::Parser::Functions
  newfunction(:katello_config_value, :type => :rvalue) do |args|
    val = Util::Puppet::config_value(args[0])
    # treat NONE as nil only when default value is provided
    val = nil if args[1] and val == 'NONE'
    return val || args[1]
  end
end
