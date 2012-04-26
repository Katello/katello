begin
  require File.expand_path('/usr/share/katello/lib/util/password.rb')
rescue LoadError
  STDERR.puts "Katello was not installed on this host - passwords won't be encrypted"
  # define dummy encrypt functions that does nothing
  module Password
    def Password.encrypt(text); return text; end
  end
end

module Puppet::Parser::Functions
  newfunction(:katello_passencrypt, :type => :rvalue) do |args|
    return Password.encrypt(args[0])
  end
end
