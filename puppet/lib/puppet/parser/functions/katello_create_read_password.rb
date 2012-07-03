module Puppet::Parser::Functions
  # returns content of password file or creates random one (if not exists)
  newfunction(:katello_create_read_password, :type => :rvalue) do |args|
    filename = args[0]
    if File.exists? filename
      IO.read(filename).chomp
    else
      # Ruby 1.8 does not have SecureRandom but openssl is installed
      randomhash = `openssl rand -base64 24`
      File.open(filename, 'w') {|f| f.write(randomhash) }
      randomhash
    end
  end
end
