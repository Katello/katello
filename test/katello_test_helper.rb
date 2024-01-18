require 'test_helper'
require 'factory_bot_rails'
require "webmock/minitest"
require 'mocha/minitest'
require 'set'
require 'robottelo/reporter/attributes'

require "#{Katello::Engine.root}/test/support/minitest/spec/shared_examples"
require "#{Katello::Engine.root}/spec/models/model_spec_helper"
require "#{Katello::Engine.root}/spec/helpers/locale_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/organization_helper_methods"
require "#{Katello::Engine.root}/test/support/vcr"
require "#{Katello::Engine.root}/test/support/controller_support"
require "#{Katello::Engine.root}/test/support/capsule_support"
require "#{Katello::Engine.root}/test/support/export_support"
require "#{Katello::Engine.root}/test/support/fixtures_support"
require "#{Katello::Engine.root}/test/support/pulp3_support"

require 'dynflow/testing'
Mocha::Mock.include Dynflow::Testing::Mimic
Dynflow::Testing.logger_adapter = Dynflow::LoggerAdapters::Delegator.new(Rails.logger, Rails.logger)
require 'foreman_tasks/test_helpers'
require "#{Katello::Engine.root}/test/support/actions/fixtures"
require "#{Katello::Engine.root}/test/support/actions/pulp_task"
require "#{Katello::Engine.root}/test/support/actions/remote_action"
require "#{Katello::Engine.root}/test/support/foreman_tasks/task"

FactoryBot.definition_file_paths = ["#{Katello::Engine.root}/test/factories"]
FactoryBot.find_definitions

module Minitest::Expectations
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

def load_repository_types
  Dir["#{File.expand_path("#{Katello::Engine.root}/lib/katello/repository_types", __FILE__)}/*.rb"].each do |file|
    load file
  end
end

module FixtureTestCase
  extend ActiveSupport::Concern

  included do
    extend ActiveRecord::TestFixtures

    self.use_instantiated_fixtures = false
    self.pre_loaded_fixtures = true

    Katello::FixturesSupport.set_fixture_classes(self)

    # Fixtures are copied into a separate path to combine with Foreman fixtures. This directory
    # is kept out of version control.
    self.fixture_path = "#{Rails.root}/tmp/combined_fixtures/"
    FileUtils.rm_rf(self.fixture_path) if File.directory?(self.fixture_path)
    Dir.mkdir(self.fixture_path)
    FileUtils.cp(Dir.glob("#{Katello::Engine.root}/test/fixtures/models/*"), self.fixture_path)
    FileUtils.cp(Dir.glob("#{Rails.root}/test/fixtures/*"), self.fixture_path)

    taxonomies_file = "#{self.fixture_path}/taxonomies.yml"
    taxonomies = YAML.safe_load(File.read(taxonomies_file))
    taxonomies.values.each do |taxonomy|
      next unless taxonomy['type'] == 'Organization'
      taxonomy['label'] = taxonomy['name'].tr(' ', '_')
    end
    File.write(taxonomies_file, taxonomies.to_yaml)

    set_fixture_class katello_generic_content_units: Katello::GenericContentUnit
    fixtures(:all)

    load_permissions
    load_repository_types
    configure_vcr

    before do
      #provide consistent remote name for test
      ::Katello::Pulp3::Repository.any_instance.stubs(:test_remote_name).returns(:test_remote_name)
    end
  end
end

class ActionController::TestCase
  extend Robottelo::Reporter::TestAttributes
  include LocaleHelperMethods
  include ControllerSupport
  include ForemanTasks::TestHelpers::WithInThreadExecutor

  def setup_engine_routes
    @routes = Katello::Engine.routes
  end

  def setup_foreman_routes
    @routes = ::Foreman::Application.routes
  end

  def setup_controller_defaults(is_api = false, load_engine_routes = true)
    set_user(User.current, is_api)
    set_default_locale
    setup_engine_routes if load_engine_routes
    @controller.stubs(:require_org).returns({})
    load_permissions
  end

  def set_user(user = nil, is_api = false)
    user = super(user)
    unless is_api
      session[:user] = user.id
      session[:expires_at] = 5.minutes.from_now
    end
  end

  def logout_user
    session[:user] = nil
  end

  def setup_controller_defaults_api
    setup_controller_defaults(true)
  end

  alias_method :login_user, :set_user

  # rubocop:disable Naming/AccessorMethodName
  def set_organization(org)
    session[:current_organization_id] = org.id
  end

  def stub_find_organization(org)
    Organization.stubs(:find_by_id).returns(org)
  end

  def setup_product_permissions
    @read_permission = :view_products
    @create_permission = :create_products
    @update_permission = :edit_products
    @destroy_permission = :destroy_products
    @sync_permission = :sync_products

    @auth_permissions = [@read_permission]
    @unauth_permissions = [@create_permission, @update_permission, @destroy_permission, @sync_permission]
  end

  def assert_response_ids(response, expected)
    body = JSON.parse(response.body)
    found_ids = body['results'].map { |item| item['id'] }
    refute_empty expected
    assert_equal expected.sort, found_ids.sort
  end

  def assert_response(type, message = nil)
    if type == :success
      if response.body.present? && /json/.match(response.headers['Content-Type'])
        json_body = JSON.parse(response.body)
        if json_body.is_a?(Hash)
          assert_nil json_body['error']
        end
      end
    end
    super(type, message)
  end
end

module DynflowFullTreePlanning
  IGNORED_INPUT = [:remote_user, :remote_cp_user].freeze

  def plan_action_tree(action_class, *args, **kwargs)
    Rails.application.dynflow.world.plan(action_class, *args, **kwargs)
  end

  def assert_tree_planned_steps(execution_plan, action_class)
    found_steps = execution_plan.steps.each_value.select { |step| action_class == step.action_class }
    assert found_steps.any?, "Action #{action_class} was not planned, there were only  #{execution_plan.steps.each_value.map(&:action_class)}"
  end

  def refute_tree_planned_steps(execution_plan, action_class)
    found_steps = execution_plan.steps.each_value.select { |step| action_class == step.action_class }
    assert_empty found_steps, "Found unexpected action: #{action_class}"
  end

  def assert_tree_planned_with(execution_plan, action_class, expected_input = nil)
    found_steps = execution_plan.run_steps.select { |step| action_class == step.action_class }
    assert found_steps.any?, "Action #{action_class} was not planned, there were only #{execution_plan.run_steps.map { |s| s.action_class }}"
    if expected_input
      input_matched = found_steps.select do |step|
        step.action(execution_plan).input.except(*IGNORED_INPUT) == expected_input.with_indifferent_access
      end
      assert input_matched.any?, pretty_print_differences(execution_plan, expected_input, found_steps)
    elsif block_given?
      found_steps.each do |step|
        yield step.action(execution_plan).input.except(*IGNORED_INPUT)
      end
    end
  end

  def refute_tree_planned(execution_plan, action_class)
    found_steps = execution_plan.run_steps.select { |step| action_class == step.action_class }
    assert_empty found_steps, "Found enexpected action: #{action_class}"
  end

  def pretty_print_differences(execution_plan, expected_input, steps)
    output = steps.map do |step|
      pretty_print_difference(expected_input, step.action(execution_plan).input)
    end
    output.join("\n")
  end

  def pretty_print_value(value)
    value.nil? ? 'nil' : value
  end

  def pretty_print_difference(expected_input, actual_input)
    output = []

    missing_keys = expected_input.keys.map(&:to_sym) - actual_input.keys.map(&:to_sym)
    output << "Missing input #{missing_keys}, but were missing." if missing_keys.any?

    unexpected_keys = actual_input.keys.map(&:to_sym) - expected_input.keys.map(&:to_sym) - [:remote_user, :remote_cp_user]
    output << "Unexpected input #{unexpected_keys} present." if unexpected_keys.any?

    expected_input.each do |key, value|
      if value != actual_input[key]
        output << "Input #{key} was expected to be #{pretty_print_value(value)}, but instead was #{pretty_print_value(actual_input[key])}."
      end
    end

    output.join('  ')
  end
end

class ActiveSupport::TestCase
  extend Robottelo::Reporter::TestAttributes
  include FactoryBot::Syntax::Methods
  include FixtureTestCase
  include ForemanTasks::TestHelpers::WithInThreadExecutor
  include DynflowFullTreePlanning

  before do
    stub_ping
    stub_certs
  end

  teardown do
    SETTINGS[:katello][:candlepin][:bulk_load_size] = 1000
  end

  def self.stubbed_ping_response
    status = {:services => {}, :status => Katello::Ping::OK_RETURN_CODE}
    (::Katello::Ping.services + [:pulp3]).each do |service|
      status[:services][service] = {:status => Katello::Ping::OK_RETURN_CODE}
    end
    status
  end

  def recording_mode?
    ['all', 'new_episodes'].include?(ENV['mode'])
  end

  def stub_certs
    unless recording_mode?
      Cert::Certs.stubs(:ca_cert).returns("file")
      Cert::Certs.stubs(:ssl_client_cert).returns("ssl_client_cert")
      Cert::Certs.stubs(:ssl_client_key).returns("ssl_client_key")
    end
  end

  def stub_constant(klass, const, value)
    old = klass.const_get(const)
    klass.send(:remove_const, const)
    klass.const_set(const, value)
    yield
  ensure
    klass.send(:remove_const, const)
    klass.const_set(const, old)
  end

  def self.stub_ping
    Katello::Ping.stubs(:ping).returns(stubbed_ping_response)
  end

  def stub_organization_creator
    Katello::OrganizationCreator.any_instance.stubs(:create_backend_objects!).returns
  end

  def stub_ping
    self.class.stub_ping
  end

  def set_user(user = users(:admin))
    user = User.unscoped.find(user.id) if user.id
    User.current = user
  end

  def set_organization(org)
    Organization.current = org
  end

  def get_organization(org = :empty_organization)
    taxonomies(org)
  end

  def fix_organization_mismatches(org)
    org.location_ids += org.hosts.pluck(:location_id)
    org.save!
  end

  def mock_active_records(*records)
    records.each do |record|
      record.class.stubs(:instantiate).with(has_entry('id', record.id.to_s), instance_of(Hash)).returns(record)
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
                       :format => 'hash', :locals => {:resource => resource}, :scope => OpenStruct.new(:params => {})).render
  end

  def assert_service_not_used(service_class)
    service_class.any_instance.expects(:backend_data).never
    yield
  end

  def assert_service_used(service_class)
    service_class.any_instance.expects(:fetch_backend_data).returns({})
    yield
  end

  def stub_cp_consumer_with_uuid(uuid)
    cp_consumer_user = ::Katello::CpConsumerUser.new
    cp_consumer_user.uuid = uuid
    cp_consumer_user.login = uuid
    User.stubs(:current).returns(cp_consumer_user)
  end

  def set_default_location
    Setting[:default_location_subscribed_hosts] = Location.first.title
  end

  def set_ca_file
    Setting[:ssl_ca_file] = File.join("#{Katello::Engine.root}", "/ca/redhat-uep.pem")
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
  stubs.each_key do |attr|
    unless model_class.lazy_attributes.include?(attr)
      fail "#{attr} is not a lazy attribute for #{model_class}, expected one of #{model_class.lazy_attributes}"
    end
  end
  target.stubs(stubs)
end

def read_test_file_data(name)
  File.read(Katello::Engine.root + name)
end
