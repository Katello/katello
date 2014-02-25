require 'test_helper'
require 'factory_girl_rails'
require "webmock/minitest"
require "mocha/setup"

require "#{Katello::Engine.root}/test/support/minitest/spec/shared_examples"
require "#{Katello::Engine.root}/spec/helpers/login_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/locale_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/authorization_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/organization_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/system_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/product_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/repository_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/search_helper_methods"
require "#{Katello::Engine.root}/spec/models/model_spec_helper"
require "#{Katello::Engine.root}/spec/support/shared_examples/protected_action_shared_examples"
require "#{Katello::Engine.root}/spec/support/custom_matchers"
require "#{Katello::Engine.root}/test/support/vcr"
require "#{Katello::Engine.root}/test/support/runcible"
require "#{Katello::Engine.root}/test/support/auth_support"
require "#{Katello::Engine.root}/test/support/controller_support"
require "#{Katello::Engine.root}/test/support/search_service"

require 'dynflow/testing'
Mocha::Mock.send :include, Dynflow::Testing::Mimic
Dynflow::Testing.logger_adapter.level = 1
require "#{Katello::Engine.root}/test/support/actions/fixtures"
require "#{Katello::Engine.root}/test/support/actions/pulp_task"
require "#{Katello::Engine.root}/test/support/actions/remote_action"
require "#{Katello::Engine.root}/test/support/foreman_tasks/task"

FactoryGirl.definition_file_paths = ["#{Katello::Engine.root}/test/factories"]
FactoryGirl.find_definitions

Katello::Glue::Event.disabled = true

module MiniTest::Expectations
  infect_an_assertion :assert_redirected_to, :must_redirect_to
  infect_an_assertion :assert_template, :must_render_template
  infect_an_assertion :assert_response, :must_respond_with
  infect_an_assertion :assert_routing, :must_route_to, :do_not_flip
  infect_an_assertion :assert_recognizes, :must_recognize, :do_not_flip
end

module FixtureTestCase
  extend ActiveSupport::Concern

  included do
    extend ActiveRecord::TestFixtures

    self.use_transactional_fixtures = true
    self.use_instantiated_fixtures = false
    self.pre_loaded_fixtures = true

    self.set_fixture_class :katello_activation_keys => "Katello::ActivationKey"
    self.set_fixture_class :katello_content_view_repositories => "Katello::ContentViewRepository"
    self.set_fixture_class :katello_content_view_environments => "Katello::ContentViewEnvironment"
    self.set_fixture_class :katello_content_views => "Katello::ContentView"
    self.set_fixture_class :katello_content_view_puppet_modules => "Katello::ContentViewPuppetModule"
    self.set_fixture_class :katello_content_view_version_environments => "Katello::ContentViewVersionEnvironment"
    self.set_fixture_class :katello_content_view_versions => "Katello::ContentViewVersion"
    self.set_fixture_class :katello_distributors => "Katello::Distributor"
    self.set_fixture_class :katello_environment_priors => "Katello::EnvironmentPrior"
    self.set_fixture_class :katello_environments => "Katello::KTEnvironment"
    self.set_fixture_class :katello_erratum_filter_rules => "Katello::ErratumFilterRule"
    self.set_fixture_class :katello_filters => "Katello::Filter"
    self.set_fixture_class :katello_gpg_keys => "Katello::GpgKey"
    self.set_fixture_class :katello_help_tips => "Katello::HelpTip"
    self.set_fixture_class :katello_notices => "Katello::Notice"
    self.set_fixture_class :katello_package_filter_rules => "Katello::PackageFilterRule"
    self.set_fixture_class :katello_package_group_filter_rules => "Katello::PackageGroupFilterRule"
    self.set_fixture_class :katello_permissions => "Katello::Permission"
    self.set_fixture_class :katello_products => "Katello::Product"
    self.set_fixture_class :katello_providers => "Katello::Provider"
    self.set_fixture_class :katello_repositories => "Katello::Repository"
    self.set_fixture_class :katello_resource_types => "Katello::ResourceType"
    self.set_fixture_class :katello_roles_users => "Katello::RoleUser"
    self.set_fixture_class :katello_roles => "Katello::Role"
    self.set_fixture_class :katello_sync_plans => "Katello::SyncPlan"
    self.set_fixture_class :katello_system_groups => "Katello::SystemGroup"
    self.set_fixture_class :katello_systems => "Katello::System"
    self.set_fixture_class :katello_system_system_groups => "Katello::SystemSystemGroup"
    self.set_fixture_class :katello_task_statuses => "Katello::TaskStatus"
    self.set_fixture_class :katello_user_notices => "Katello::UserNotice"

    load_fixtures
    self.fixture_path = "#{Katello::Engine.root}/test/fixtures/models"
    fixtures(:all)
  end

  module ClassMethods

    def before_suite
      @loaded_fixtures = load_fixtures

      @@admin = ::User.find(@loaded_fixtures['users']['admin']['id'])
      @@admin.remote_id = @@admin.login
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

  def setup_controller_defaults(is_api = false)
    set_user(User.current, is_api)
    set_default_locale
    setup_engine_routes
  end

  def set_user(user = nil, is_api = false)
    if user.is_a?(UserPermission) || user.is_a?(UserPermissionSet)
      permissions = user
      user = users(:restricted)
    end

    user ||= users(:admin)
    user = User.find(user)
    User.current = user

    if permissions
      permissions.call(Katello::AuthorizationSupportMethods::UserPermissionsGenerator.new(user))
    end
    unless is_api
      session[:user] = user.id
      session[:expires_at] = 5.minutes.from_now
    end
  end

  def setup_controller_defaults_api
    setup_controller_defaults(true)
    @controller.stubs(:require_org).returns({})
  end

  alias_method :login_user, :set_user

  def set_organization(org)
    session[:current_organization_id] = org.id
  end

  def stub_find_organization(org)
    Organization.stubs(:without_deleting).returns(stub(:having_name_or_label => [org]))
  end
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include FixtureTestCase

  def get_organization(org = nil)
    saved_user = User.current
    User.current = User.find(users(:admin))

    org = org.nil? ? :empty_organization : org
    organization = Organization.find(taxonomies(org.to_sym))
    organization.setup_label_from_name
    organization.save!

    User.current = saved_user
    organization
  end

end

def disable_glue_layers(services=[], models=[], force_reload=false)
  @@model_service_cache ||= {}
  @@model_service_cache = {} if force_reload
  change = false

  Katello.config[:use_cp]            = services.include?('Candlepin') ? false : true
  Katello.config[:use_pulp]          = services.include?('Pulp') ? false : true
  Katello.config[:use_elasticsearch] = services.include?('ElasticSearch') ? false : true

  cached_entry = {
    :cp => Katello.config.use_cp,
    :pulp => Katello.config.use_pulp,
    :es => Katello.config.use_elasticsearch
  }

  models.each do |model|
    if @@model_service_cache[model] != cached_entry
      begin
        Katello.send(:remove_const, model)
        load "#{Katello::Engine.root}/app/models/katello/#{model.underscore}.rb"
      rescue NameError
        Object.send(:remove_const, model)
        if model == 'Organization'
          load "#{Rails.root}/app/models/taxonomies/#{model.underscore}.rb"
        else
          load "#{Rails.root}/app/models/#{model.underscore}.rb"
        end
      end
      if model == 'User'
        # Ugly hack to force the model to be loaded properly
        # Without this, the glue layer functions are not available
        User.first

        # include the concern again after User reloading
        User.send :include, Katello::Concerns::UserExtensions
      end
      if model == 'Organization'
        # Ugly hack to force the model to be loaded properly
        # Without this, the glue layer functions are not available
        Organization.first

        # include the concern again after Organization reloading
        Organization.send :include, Katello::Concerns::OrganizationExtensions
      end

      @@model_service_cache[model] = cached_entry
      change = true
    end
  end

  if change
    ActiveSupport::Dependencies::Reference.clear!
    FactoryGirl.reload
  end
end
