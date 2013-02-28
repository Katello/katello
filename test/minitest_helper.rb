ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'minitest/autorun'
require 'minitest/rails'
require 'json'
require 'support/warden_support'
require 'mocha/setup'

class MiniTest::Rails::ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
  self.pre_loaded_fixtures = true
  self.fixture_path = File.expand_path('../fixtures/models', __FILE__)
  self.set_fixture_class :environments => KTEnvironment
end

class MiniTest::Rails::Spec
  include ActiveSupport::Testing::Assertions
  include Warden::Test::Helpers
  include WardenSupport

  class << self
    alias context describe
  end

  def build_message(*args)
    args[1].gsub(/\?/, '%s') % args[2..-1]
  end
end

class Minitest::Rails::ActionController::TestCase
  include Warden::Test::Helpers
  include WardenSupport
end

def configure_vcr
  require "vcr"

  mode = ENV['mode'] ? ENV['mode'].to_sym : :none

  if ENV['record'] == "false" && mode == :none
    raise "Record flag is not applicable for mode 'none', please use with 'mode=all'"
  end

  VCR.configure do |c|
    c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
    c.hook_into :webmock

    if ENV['record'] == "false" && mode != :none
      uri = URI.parse(Katello.config.pulp.url)
      c.ignore_hosts uri.host
    end

    c.default_cassette_options = {
      :record => mode,
      :match_requests_on => [:method, :path, :params],
      :serialize_with => :syck
    }

    begin
      c.register_request_matcher :body_json do |request_1, request_2|
        begin
          json_1 = JSON.parse(request_1.body)
          json_2 = JSON.parse(request_2.body)

          json_1 == json_2
        rescue
          #fallback incase there is a JSON parse error
          request_1.body == request_2.body
        end
      end
    rescue => e
      #ignore the warning thrown about this matcher already being resgistered
    end

    begin
      c.register_request_matcher :params do |request_1, request_2|
        URI(request_1.uri).query == URI(request_2.uri).query
      end
    rescue => e
      #ignore the warning thrown about this matcher already being resgistered
    end

  end
end

def configure_runcible
  if Katello.config[:use_pulp]
    uri = URI.parse(Katello.config.pulp.url)

    Runcible::Base.config = {
      :url      => "#{uri.scheme}://#{uri.host}",
      :api_path => uri.path,
      :user     => "admin",
      :oauth    => {:oauth_secret => Katello.config.pulp.oauth_secret,
                    :oauth_key    => Katello.config.pulp.oauth_key }
    }

    Runcible::Base.config[:logger] = 'stdout' if ENV['logging'] == "true"
  end
end

def disable_glue_layers(services=[], models=[], force_reload=false)
  @@model_service_cache ||= {}
  @@model_service_cache = {} if force_reload
  change = false

  Katello.config[:use_cp]            = services.include?('Candlepin') ? false : true
  Katello.config[:use_pulp]          = services.include?('Pulp') ? false : true
  Katello.config[:use_foreman]       = services.include?('Foreman') ? false : true
  Katello.config[:use_elasticsearch] = services.include?('ElasticSearch') ? false : true

  cached_entry = {:cp=>Katello.config.use_cp, :pulp=>Katello.config.use_pulp, :es=>Katello.config.use_elasticsearch,
                  :foreman => Katello.config.use_foreman}
  models.each do |model|
    if @@model_service_cache[model] != cached_entry
      Object.send(:remove_const, model)
      load "app/models/#{model.underscore}.rb"
      @@model_service_cache[model] = cached_entry
      change = true
    end
  end

  if change
    ActiveSupport::Dependencies::Reference.clear!
    FactoryGirl.reload
  end
end


class ResourceTypeBackup
  @@types_backup = ResourceType::TYPES.clone

  def self.restore
    ResourceType::TYPES.clear
    ResourceType::TYPES.merge!(@@types_backup)
  end
end


class CustomMiniTestRunner
  class Unit < MiniTest::Unit

    def before_suites
      # code to run before the first test
      configure_vcr
    end

    def after_suites
      # code to run after the last test
    end

    def _run_suites(suites, type)
      begin
        if ENV['suite']
          suites = suites.select do |suite|
                     suite.name == ENV['suite']
                   end
        end

        before_suites
        super(suites, type)
      ensure
        after_suites
      end
    end

    def _run_suite(suite, type)
      begin
        User.current = nil  #reset User.current
        suite.before_suite if suite.respond_to?(:before_suite)
        super(suite, type)
      ensure
        suite.after_suite if suite.respond_to?(:after_suite)
        ResourceTypeBackup.restore
      end
    end

  end
end

MiniTest::Unit.runner = CustomMiniTestRunner::Unit.new
