# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

# apply a prefix to the application, if one is defined
# e.g. http://some.server.com/prefix where '/prefix' is defined by env variable

if Katello.config.embed_yard_documentation
  prefixed_router = Class.new YARD::Server::Router do
    prefix  = Katello.early_config.url_prefix + '/yard/'
    methods = { :docs_prefix => 'docs', :list_prefix => 'list', :search_prefix => 'search' }

    methods.each do |method, suffix|
      define_method(method) { prefix[1..-1] + suffix }
    end
  end

  libraries = { 'katello' => [YARD::Server::LibraryVersion.new('katello', nil, "#{Rails.root}/.yardoc")] }
  use YARD::Server::RackMiddleware,
      :libraries      => libraries,
      :options        => { :router => prefixed_router, :incremental => true, :single_library => true },
      :server_options => { }

  YARD::Logger.instance.level = 0
end

map Katello.config.url_prefix do
  run Src::Application
end
