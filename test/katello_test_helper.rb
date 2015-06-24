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
require "#{Katello::Engine.root}/spec/helpers/search_helper_methods"
require "#{Katello::Engine.root}/test/support/vcr"
require "#{Katello::Engine.root}/test/support/runcible"
require "#{Katello::Engine.root}/test/support/controller_support"
require "#{Katello::Engine.root}/test/support/search_service"
require "#{Katello::Engine.root}/test/support/capsule_support"
require "#{Katello::Engine.root}/test/support/pulp/repository_support"

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

    self.set_fixture_class :katello_activation_keys => "Katello::ActivationKey"
    self.set_fixture_class :katello_content_views => "Katello::ContentView"
    self.set_fixture_class :katello_content_view_environments => "Katello::ContentViewEnvironment"
    self.set_fixture_class :katello_content_view_filters => "Katello::ContentViewFilter"
    self.set_fixture_class :katello_content_view_erratum_filter_rules => "Katello::ContentViewErratumFilterRule"
    self.set_fixture_class :katello_content_view_package_filter_rules => "Katello::ContentViewPackageFilterRule"
    self.set_fixture_class :katello_content_view_package_group_filter_rules => "Katello::ContentViewPackageGroupFilterRule"
    self.set_fixture_class :katello_content_view_puppet_modules => "Katello::ContentViewPuppetModule"
    self.set_fixture_class :katello_content_view_puppet_environments => "Katello::ContentViewPuppetEnvironment"
    self.set_fixture_class :katello_content_view_repositories => "Katello::ContentViewRepository"
    self.set_fixture_class :katello_content_view_version_environments => "Katello::ContentViewVersionEnvironment"
    self.set_fixture_class :katello_content_view_versions => "Katello::ContentViewVersion"
    self.set_fixture_class :katello_distributors => "Katello::Distributor"
    self.set_fixture_class :katello_environment_priors => "Katello::EnvironmentPrior"
    self.set_fixture_class :katello_environments => "Katello::KTEnvironment"
    self.set_fixture_class :katello_gpg_keys => "Katello::GpgKey"
    self.set_fixture_class :katello_products => "Katello::Product"
    self.set_fixture_class :katello_providers => "Katello::Provider"
    self.set_fixture_class :katello_repositories => "Katello::Repository"
    self.set_fixture_class :katello_sync_plans => "Katello::SyncPlan"
    self.set_fixture_class :katello_host_collections => "Katello::HostCollection"
    self.set_fixture_class :katello_systems => "Katello::System"
    self.set_fixture_class :katello_system_host_collections => "Katello::SystemHostCollection"
    self.set_fixture_class :katello_task_statuses => "Katello::TaskStatus"
    self.set_fixture_class :katello_errata => "Katello::Erratum"
    self.set_fixture_class :katello_erratum_packages => "Katello::ErratumPackage"
    self.set_fixture_class :katello_erratum_cves => "Katello::ErratumCve"
    self.set_fixture_class :katello_repository_errata => "Katello::RepositoryErratum"
    self.set_fixture_class :katello_system_errata => "Katello::SystemErratum"

    load_fixtures
    self.fixture_path = "#{Katello::Engine.root}/test/fixtures/models"
    fixtures(:all)

    load_permissions

    Setting::Katello.load_defaults
  end

  module ClassMethods
    def before_suite
      @loaded_fixtures = load_fixtures

      @@admin = ::User.find(@loaded_fixtures['users']['admin']['id'])
      User.current = @@admin
    end
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

  def self.run_as_admin
    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
    yield
    User.current = nil
  end

  def set_user(user = nil)
    user ||= users(:admin)
    user = User.find(user) if user.id
    User.current = user
  end

  def stubbed_ping_response
    status = {:services => {}}
    ::Katello::Ping::SERVICES.each do |service|
      status[:services][service] = {:status => Katello::Ping::OK_RETURN_CODE}
    end
    status
  end

  def stub_ping
    Katello::Ping.stubs(:ping).returns(stubbed_ping_response)
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
