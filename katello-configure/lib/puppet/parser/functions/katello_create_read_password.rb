module Puppet::Parser::Functions
  # returns content of password file or creates random one (if not exists)
  newfunction(:katello_create_read_password, :type => :rvalue) do |args|
    filename = args[0]
    if File.exists? filename
      puts "Loading random seed from #{filename}"
      IO.read(filename).chomp
    else
      # Ruby 1.8 does not have SecureRandom but openssl is installed
      puts "Generating new random seed in #{filename}"
      randomhash = `openssl rand -base64 24`
      File.open(filename, 'w', 0600) {|f| f.write(randomhash) }
      randomhash.chomp
    end
  end
end
