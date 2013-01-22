require File.expand_path('../boot', __FILE__)

require 'rails/all'
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
require "./lib/util/boot_util"


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
  if defined? WebMock and Rails.env != "test"
    WebMock.allow_net_connect!(:net_http_connect_on_start => true)
  end
else
  # In Bundler mode we load only specified groups
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)
  if defined?(Bundler)
    basic_groups = [:default, (:foreman if Katello::BootUtil.katello?)]
    groups = case Rails.env.to_sym
             when :build
               basic_groups + [:development, :build]
             when :production
               basic_groups
             when :development
               basic_groups + [:development, :debugging, :build, :development_boost]
             when :test
               basic_groups + [:development, :test, (:debugging if ENV['TRAVIS'] != 'true')]
             else
               raise "unknown environment #{Rails.env.to_sym}"
             end.compact
    Bundler.require *groups
  end
end

module Src
  class Application < Rails::Application    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{Rails.root}/lib)

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
    config.action_view.javascript_expansions[:defaults] = ['jquery-1.4.2', 'jquery.ui-1.8.1/jquery-ui-1.8.1.custom.min', 'jquery-ujs/rails']

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
    config.generators do |g|
      g.test_framework :rspec
      g.template_engine :haml
    end

    # Load the katello.yml.  Details from it are used in setting some config elements of the environment.
    katello_config = YAML.load_file('/etc/katello/katello.yml') rescue nil
    if katello_config.nil?
      katello_config = YAML.load_file("#{Rails.root}/config/katello.yml") rescue nil
    end

    # Configure the mailer.
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true

    host = "127.0.0.1" # default
    protocol = "http"  # default
    port = nil
    unless katello_config['common'].nil?
      host = katello_config['common']['host'] unless katello_config['common']['host'].nil?
      port = katello_config['common']['port'].to_s unless katello_config['common']['port'].nil?
      unless katello_config['common']['use_ssl'].nil?
        if katello_config['common']['use_ssl']
          protocol = "https"
        end
      end
    end
    prefix = ENV['RAILS_RELATIVE_URL_ROOT'] || '/'
    if (port.nil?)
      config.action_mailer.default_url_options = {:host => host + prefix, :protocol => protocol}
    else
      config.action_mailer.default_url_options = {:host => host + ':' + port + prefix, :protocol => protocol}
    end

    config.after_initialize do
      require 'monkeys/fix_string_interpolate'
      require "string"
    end


    # set actions to profile (eg. %w(user_sessions#new))
    # profiles will be stored in tmp/profiles/
    config.do_profiles = []

    # if paranoia is set to true even children of Exception will be rescued
    config.exception_paranoia = false
  end
end

old_fast_gettext = !defined?(FastGettext::Version) ||
    (FastGettext::Version.split('.').map(&:to_i) <=> [0, 6, 8]) == -1 # compare versions x.x.x <= 0.6.7

FastGettext.add_text_domain('app', { :path => 'locale', :type => :po, :ignore_fuzzy => true }.
    update(old_fast_gettext ? { :ignore_obsolete => true } : { :report_warning => false }))

FastGettext.default_text_domain = 'app'
