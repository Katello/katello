require 'test_helper'
require 'factory_girl_rails'
require "webmock/minitest"
require "mocha/setup"
require 'set'

require "#{Katello::Engine.root}/test/support/minitest/spec/shared_examples"
require "#{Katello::Engine.root}/spec/models/model_spec_helper"
require "#{Katello::Engine.root}/spec/helpers/locale_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/organization_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/system_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/product_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/repository_helper_methods"
require "#{Katello::Engine.root}/test/support/vcr"
require "#{Katello::Engine.root}/test/support/runcible"
require "#{Katello::Engine.root}/test/support/controller_support"
require "#{Katello::Engine.root}/test/support/capsule_support"
require "#{Katello::Engine.root}/test/support/pulp/repository_support"
require "#{Katello::Engine.root}/test/support/fixtures_support"

require 'dynflow/testing'
Mocha::Mock.send :include, Dynflow::Testing::Mimic
Dynflow::Testing.logger_adapter.level = 1
require "#{Katello::Engine.root}/test/support/actions/fixtures"
require "#{Katello::Engine.root}/test/support/actions/pulp_task"
require "#{Katello::Engine.root}/test/support/actions/remote_action"
require "#{Katello::Engine.root}/test/support/foreman_tasks/task"

FactoryGirl.definition_file_paths = ["#{Katello::Engine.root}/test/factories"]
FactoryGirl.find_definitions

module MiniTest::Expectations
  infect_an_assertion :assert_redirected_to, :must_redirect_to
  infect_an_assertion :assert_template, :must_render_template
  infect_an_assertion :assert_response, :must_respond_with
  infect_an_assertion :assert_routing, :must_route_to, :do_not_flip
  infect_an_assertion :assert_recognizes, :must_recognize, :do_not_flip
end

def load_permissions
  Dir["#{File.expand_path("#{Katello::Engine.root}/lib/katello/permissions", __FILE__)}/*.rb"].each do |file|
    load file
  end
end

module FixtureTestCase
  extend ActiveSupport::Concern

  included do
    extend ActiveRecord::TestFixtures

    self.use_transactional_fixtures = true
    self.use_instantiated_fixtures = false
    self.pre_loaded_fixtures = true

    Katello::FixturesSupport.set_fixture_classes(self)

    self.fixture_path = Dir.mktmpdir("katello_fixtures")
    FileUtils.cp(Dir.glob("#{Katello::Engine.root}/test/fixtures/models/*"), self.fixture_path)
    FileUtils.cp(Dir.glob("#{Rails.root}/test/fixtures/*"), self.fixture_path)
    fixtures(:all)
    FIXTURES = load_fixtures

    load_permissions
    configure_vcr

    Setting::Katello.load_defaults

    @@admin = ::User.find(FIXTURES['users']['admin']['id'])
    User.current = @@admin
  end
end

class ActionController::TestCase
  include LocaleHelperMethods
  include ControllerSupport

  def setup_engine_routes
    @routes = Katello::Engine.routes
  end

  def setup_controller_defaults(is_api = false, load_engine_routes = true)
    set_user(User.current, is_api)
    set_default_locale
    setup_engine_routes if load_engine_routes
    @controller.stubs(:require_org).returns({})
  end

  def set_user(user = nil, is_api = false)
    user = super(user)
    unless is_api
      session[:user] = user.id
      session[:expires_at] = 5.minutes.from_now
    end
  end

  def setup_controller_defaults_api
    setup_controller_defaults(true)
  end

  alias_method :login_user, :set_user

  # rubocop:disable Style/AccessorMethodName
  def set_organization(org)
    session[:current_organization_id] = org.id
  end

  def stub_find_organization(org)
    Organization.stubs(:find_by_id).returns(org)
  end
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include FixtureTestCase

  before do
    stub_ping
  end

  def self.stubbed_ping_response
    status = {:services => {}}
    ::Katello::Ping::SERVICES.each do |service|
      status[:services][service] = {:status => Katello::Ping::OK_RETURN_CODE}
    end
    status
  end

  def self.stub_ping
    Katello::Ping.stubs(:ping).returns(stubbed_ping_response)
  end

  def stub_ping
    self.class.stub_ping
  end

  def self.run_as_admin
    User.current = User.find(FIXTURES['users']['admin']['id'])
    yield
    User.current = nil
  end

  def set_user(user = nil)
    user ||= users(:admin)
    user = User.find(user) if user.id
    User.current = user
  end

  def get_organization(org = nil)
    saved_user = User.current
    User.current = User.find(users(:admin))
    org = org.nil? ? :empty_organization : org
    organization = Organization.find(taxonomies(org.to_sym))
    organization.stubs(:label_not_changed).returns(true)
    organization.setup_label_from_name
    organization.save!
    User.current = saved_user
    organization
  end

  def mock_active_records(*records)
    records.each do |record|
      record.class.stubs(:instantiate).with(has_entry('id', record.id.to_s)).returns(record)
      record.stubs(:reload).returns(record)
    end
  end

  def assert_equal_arrays(array1, array2)
    assert_equal array1.sort, array2.sort
  end

  def refute_equal_arrays(array1, array2)
    refute_equal array1.sort, array2.sort
  end

  def render_rabl(filepath, resource)
    Rabl::Renderer.new(filepath, resource, :view_path => "#{Katello::Engine.root}/app/views/",
                       :format => 'hash', :locals => {:resource => resource}).render
  end

  def assert_service_not_used(service_class)
    service_class.any_instance.expects(:backend_data).never
    yield
  end

  def assert_service_used(service_class)
    service_class.any_instance.expects(:backend_data).returns({})
    yield
  end
end

def disable_lazy_accessors
  models = Katello::Model.subclasses.find_all do |model|
    model.ancestors.include?(Katello::LazyAccessor)
  end
  models.each do |model|
    target = model.is_a?(Class) ? model.any_instance : target
    target.stubs(:lazy_attribute_get)
  end
end

def stub_lazy_accessors(model, stubs)
  if model.is_a?(Class)
    target = model.any_instance
    model_class = model
  else
    target = model
    model_class = model.class
  end
  return unless model_class.ancestors.include?(Katello::LazyAccessor)
  stubs.keys.each do |attr|
    unless model_class.lazy_attributes.include?(attr)
      fail "#{attr} is not a lazy attribute for #{model_class}, expected one of #{model_class.lazy_attributes}"
    end
  end
  target.stubs(stubs)
end
