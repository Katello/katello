require File.expand_path('../boot', __FILE__)

require 'rails/all'
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

path = File.expand_path("../lib", File.dirname(__FILE__))
$LOAD_PATH << path unless $LOAD_PATH.include? path
require 'katello/load_configuration'
require 'katello/logging'
require 'katello/url_constrained_cookie_store'

# bundler_ext does not support inline gem's currently so we have to mount
# the engine through a requires instead of within the Gemfile
require File.expand_path("../engines/bastion/lib/bastion", File.dirname(__FILE__))

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if File.exist?(File.expand_path('../../Gemfile.in', __FILE__))
  # In bundler_ext mode we always load all groups except the testing group
  # which can cause problems mocking objects for production or development envs.
  require 'bundler_ext'
  BundlerExt.system_require(File.expand_path('../../Gemfile.in', __FILE__), :all)

  # Webmock rubygem have very strong default setting - it blocks all HTTP connections
  # after it is required. Therefore we want to turn off this behavior for all environments
  # except test since with bundler_ext we load ALL groups by default.
  if defined?(WebMock) && Rails.env != "test"
    WebMock.allow_net_connect!(:net_http_connect_on_start => true)
  end
else
  # In Bundler mode we load only specified groups
  unless ENV['BUNDLE_GEMFILE']
    ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)
  end
  if defined?(Bundler)
    basic_groups = [:default, :optional]
    basic_groups.push :pulp if Katello.early_config.katello?
    groups = case Rails.env.to_sym
             when :build
               basic_groups + [:development, :build, :assets]
             when :production
               basic_groups
             when :development
               basic_groups + [:development, :debugging, :build, :assets]
             when :test
               # TODO: replace ENV['TRAVIS'] with configuration
               basic_groups + [:development, :test, (:debugging if ENV['TRAVIS'] != 'true')]
             else
               fail "unknown environment #{Rails.env.to_sym}"
             end.compact
    Bundler.require(*groups)
  end
end

require 'orchestrate'

module Src
  class Application < Rails::Application

    require 'katello/middleware/log_request_uuid'
    config.middleware.insert_after ActionDispatch::RequestId, Katello::Middleware::LogRequestUUID

    require 'katello/middleware/log_silencer'
    config.middleware.swap Rails::Rack::Logger, Katello::Middleware::LogSilencer

    # use dabase configuration form katello.yml instead database.yml
    config.class_eval do
      def database_configuration
        Katello.database_configs
      end
    end

    # Setup additional routes by loading all routes file from routes directory
    config.paths["config/routes"] += Dir[Rails.root.join("config/routes/**/*.rb")]

    # set the relative url for rails
    config.relative_url_root = Katello.config.url_prefix

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths   += %W(#{Rails.root}/app/lib/)
    config.eager_load_paths += Orchestrate.eager_load_paths


    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    #config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    #config.i18n.default_locale = :en

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.generators do |g|
      g.test_framework :mini_test, :spec => false, :fixture => false
      g.template_engine :haml
    end

    # Configure the mailer.
    config.action_mailer.delivery_method       = :sendmail
    config.action_mailer.perform_deliveries    = true
    config.action_mailer.raise_delivery_errors = true

    config.action_mailer.default_url_options = {
        :host => [
            Katello.config.host,
            (":#{Katello.config.port}" if Katello.config.port),
            Katello.config.url_prefix].compact.join,
        :protocol => Katello.config.use_ssl ? 'https' : 'http'
    }

    config.after_initialize do |app|
      require 'string_to_bool'
      #default all non-matched route to our special 404 page
      # cannot be added to routes.rb due to conflicting with engines
      app.routes.append{match '/api*a', :to => 'api/v1/errors#render_404'}
      app.routes.append{match '*a', :to => 'errors#routing'}

      Orchestrate.eager_load!
    end

    # logging configuration
    config.colorize_logging = Katello.config.logging.colorize

    # When running under Rails last caller is "/usr/share/katello/config.ru:1" but when running standalone
    # last caller is "script/delayed_job:3".
    if caller.last =~ /script\/delayed_job:\d+$/ ||
        ((caller[-10..-1] || []).any? {|l| l =~ /\/rake/} && ARGV.include?("jobs:work"))
      Katello::Logging.configure(:prefix => 'delayed_')
      Delayed::Worker.logger = Logging.logger['app']
    else
      Katello::Logging.configure
    end

    config.logger = Logging.logger['app']
    config.active_record.logger = Logging.logger['sql']

    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.initialize_on_precompile = false

    config.assets.paths << Rails.root.join("app", "assets")

    config.assets.precompile << proc do |path|
      if path =~ /\.(css|js)\z/
        full_path = Rails.application.assets.resolve(path).to_path
        app_assets_path = Rails.root.join('app', 'assets').to_path
        if full_path.starts_with? app_assets_path
          puts "including asset: " + full_path
          true
        else
          puts "excluding asset: " + full_path
          false
        end
      else
        false
      end
    end

  end
end

# add a default format for date... without this, rendering a datetime included "UTC" as of the string
Time::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M:%S"

old_fast_gettext = !defined?(FastGettext::Version) ||
    # compare versions x.x.x <= 0.6.7
    (FastGettext::Version.split('.').map(&:to_i) <=> [0, 6, 8]) == -1

FastGettext.add_text_domain('katello', {
  :path => File.expand_path("../../locale", __FILE__),
  :type => :po,
  :ignore_fuzzy => true
}.update(old_fast_gettext ? {:ignore_obsolete => true} : {:report_warning => false}))

FastGettext.default_text_domain = 'katello'

if Katello.config.use_pulp && !Object.constants.include?(:Fort) && false
  require File.expand_path("../engines/fort/lib/fort", File.dirname(__FILE__))
end
