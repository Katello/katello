ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'minitest/autorun'
require 'minitest/rails'


class MiniTest::Rails::ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
  self.fixture_path = File.expand_path('../fixtures/models', __FILE__)
  self.set_fixture_class :environments => KTEnvironment
end

def configure_vcr
  require "vcr"

  mode = ENV['mode'] ? ENV['mode'] : :all

  VCR.configure do |c|
    c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
    c.hook_into :webmock
    c.default_cassette_options = { :record => mode.to_sym } #record_mode } #forcing all requests to Pulp currently
  end
end

def configure_runcible
  uri = URI.parse(AppConfig.pulp.url)
  Runcible::Base.config = { 
    :url      => "#{uri.scheme}://#{uri.host}",
    :api_path => uri.path,
    :user     => "admin",
    :oauth    => {:oauth_secret => AppConfig.pulp.oauth_secret,
                  :oauth_key    => AppConfig.pulp.oauth_key }
  }

  Runcible::Base.config[:logger] = 'stdout' if ENV['logging'] == "true"
end

def disable_glue_layers(services=[], models=[])
  @@model_service_cache ||= {}
  change = false
  AppConfig.use_cp = false if services.include?('Candlepin')
  AppConfig.use_pulp = false if services.include?('Pulp')
  AppConfig.use_elasticsearch = false if services.include?('ElasticSearch')

  cached_entry = {:cp=>AppConfig.use_cp, :pulp=>AppConfig.use_cp, :es=>AppConfig.use_elasticsearch}
  models.each do |model|
    if @@model_service_cache[model] != cached_entry
      Object.send(:remove_const, model)
      load "app/models/#{model.underscore}.rb"
      @@model_service_cache[model] = cached_entry
      change = true
    end
  end

  FactoryGirl.reload if change
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
        ResourceTypeBackup.restore
      end
    end

    def _run_suite(suite, type)
      begin
        User.current = nil  #reset User.current
        suite.before_suite if suite.respond_to?(:before_suite)
        super(suite, type)
      ensure
        suite.after_suite if suite.respond_to?(:after_suite)
      end
    end

  end
end

MiniTest::Unit.runner = CustomMiniTestRunner::Unit.new
