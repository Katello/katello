=begin
require 'rails'
require 'minitest/autorun'
require 'json'
require 'mocha/setup'

require File.expand_path("../support.rb",  __FILE__)
require File.expand_path("../support/pulp/task_support.rb",  __FILE__)
require File.expand_path("../../lib/monkeys/foreign_keys_postgresql.rb",  __FILE__)

class MiniTest::Rails::ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
  self.pre_loaded_fixtures = true
  self.set_fixture_class :environments => KTEnvironment

  def default_url_options
    { :script_name => ActionController::Base.config.relative_url_root
    }.merge(Rails.application.routes.default_url_options)
  end

  def override_config(options)
    config = Katello::Configuration::Node.new(Katello.config.to_hash.update options)
    Katello.stubs(:config).returns(config)
  end
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
  include ControllerSupport
  include Support::SearchService
end

module VCR
  def self.live?
    VCR.configuration.default_cassette_options[:record] != :none
  end
end

def configure_vcr
  require "vcr"

  mode = ENV['mode'] ? ENV['mode'].to_sym : :none

  if ENV['record'] == "false" && mode == :none
    raise "Record flag is not applicable for mode 'none', please use with 'mode=all'"
  end

  if mode != :none
    system("sudo cp -rf #{File.expand_path('../', __FILE__)}/fixtures/test_repos /var/www/")
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
      :match_requests_on => [:method, :path, :params, :body_json],
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
    runcible_config = {
      :url      => "#{uri.scheme}://#{uri.host}",
      :api_path => uri.path,
      :user     => "admin",
      :oauth    => {:oauth_secret => Katello.config.pulp.oauth_secret,
                    :oauth_key    => Katello.config.pulp.oauth_key }
    }

    runcible_config[:logger] = 'stdout' if ENV['logging'] == "true"
    Katello.pulp_server = Runcible::Instance.new(runcible_config)
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

begin # load reporters for RubyMine if available
  require 'minitest/reporters'
  MiniTest::Reporters.use!
rescue LoadError
  # ignored
end if ENV['RUBYMINE']
=end
