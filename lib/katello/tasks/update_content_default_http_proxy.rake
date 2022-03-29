require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Sets the content default HTTP proxy to an existing HTTP proxy based on supplied URL."
  task :update_default_http_proxy => :environment do
    options = {}
    o = OptionParser.new
    o.banner = "Usage: rake katello:update_content_default_http_proxy -- --name HTTP_PROXY_NAME --url HTTP_PROXY_URL [--user HTTP_PROXY_USER] [--password HTTP_PROXY_PASSWORD]"
    o.on("-n", "--name HTTP_PROXY_NAME") do |name|
      options[:name] = name
    end
    o.on("-u", "--url HTTP_PROXY_URL") do |url|
      options[:url] = url
    end
    o.on("-o", "--port port") do |port|
      options[:port] = port
    end
    o.on("-p", "--password HTTP_PROXY_PASSWORD") do |password|
      options[:password] = password
    end
    o.on("-s", "--user HTTP_PROXY_USER") do |username|
      options[:username] = username
    end
    o.on("-h, --help", "Prints this help") do
      puts o
      exit
    end
    ordered_args = o.order!(ARGV) {}
    o.parse!(ordered_args)

    unless options.key?(:name)
      $stderr.print("ERROR: Missing required option for --name HTTP_PROXY_NAME")
      exit 2
    end

    unless options.key?(:url)
      $stderr.print("ERROR: Missing required option for --url HTTP_PROXY_URL")
      exit 2
    end

    User.current = User.anonymous_api_admin
    http_proxy = HttpProxy.where(name: options[:name]).first

    uri = URI(options[:url])
    uri.user = nil
    uri.password = nil
    uri.port = options[:port] if options[:port]
    sanitized_url = uri.to_s

    if http_proxy
      Setting['content_default_http_proxy'] = http_proxy.name
      http_proxy.update!(url: sanitized_url,
                                   username: options[:username], password: options[:password])
      puts "Content default HTTP proxy set to #{http_proxy.name_and_url}."
    else
      new_proxy = ::HttpProxy.new(name: options[:name], url: sanitized_url,
                                username: options[:username], password: options[:password],
                                organizations: Organization.all,
                                locations: Location.all)
      if new_proxy.save!
        Setting['content_default_http_proxy'] = new_proxy.name
        puts "Default content HTTP proxy set to #{new_proxy.name_and_url}."
      end
    end

    exit
  end
end
