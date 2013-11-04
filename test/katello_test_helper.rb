require 'test_helper'
require 'factory_girl_rails'
require "mocha/setup"

require "#{Katello::Engine.root}/test/support/minitest/spec/shared_examples"

require "#{Katello::Engine.root}/spec/helpers/login_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/locale_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/authorization_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/organization_helper_methods"
require "#{Katello::Engine.root}/spec/helpers/system_helper_methods"
require "#{Katello::Engine.root}/spec/models/model_spec_helper"
require "#{Katello::Engine.root}/spec/support/shared_examples/protected_action_shared_examples"
require "#{Katello::Engine.root}/spec/support/custom_matchers"
require "#{Katello::Engine.root}/test/support/vcr"
require "#{Katello::Engine.root}/test/support/runcible"

FactoryGirl.definition_file_paths = ["#{Katello::Engine.root}/test/factories"]
FactoryGirl.find_definitions

class ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures
  include FactoryGirl::Syntax::Methods

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
  self.pre_loaded_fixtures = true

  self.set_fixture_class :katello_activation_keys => "Katello::ActivationKey"
  self.set_fixture_class :katello_component_content_views => "Katello::ComponentContentView"
  self.set_fixture_class :katello_content_view_definition_bases => "Katello::ContentViewDefinitionBase"
  self.set_fixture_class :katello_content_view_definition_products => "Katello::ContentViewDefinitionProduct"
  self.set_fixture_class :katello_content_view_definition_repositories => "Katello::ContentViewDefinitionRepository"
  self.set_fixture_class :katello_content_view_environments => "Katello::ContentViewEnvironment"
  self.set_fixture_class :katello_content_views => "Katello::ContentView"
  self.set_fixture_class :katello_content_view_version_environments => "Katello::ContentViewVersionEnvironment"
  self.set_fixture_class :katello_content_view_versions => "Katello::ContentViewVersion"
  self.set_fixture_class :katello_distributors => "Katello::Distributor"
  self.set_fixture_class :katello_environment_priors => "Katello::EnvironmentPrior"
  self.set_fixture_class :katello_environments => "Katello::KTEnvironment"
  self.set_fixture_class :katello_filter_rules => "Katello::FilterRule"
  self.set_fixture_class :katello_filters => "Katello::Filter"
  self.set_fixture_class :katello_gpg_keys => "Katello::GpgKey"
  self.set_fixture_class :katello_help_tips => "Katello::HelpTip"
  self.set_fixture_class :katello_notices => "Katello::Notice"
  self.set_fixture_class :katello_organizations => "Katello::Organization"
  self.set_fixture_class :katello_permissions => "Katello::Permission"
  self.set_fixture_class :katello_products => "Katello::Product"
  self.set_fixture_class :katello_providers => "Katello::Provider"
  self.set_fixture_class :katello_repositories => "Katello::Repository"
  self.set_fixture_class :katello_resource_types => "Katello::ResourceType"
  self.set_fixture_class :katello_roles_users => "Katello::RoleUser"
  self.set_fixture_class :katello_roles => "Katello::Role"
  self.set_fixture_class :katello_system_groups => "Katello::SystemGroup"
  self.set_fixture_class :katello_systems => "Katello::System"
  self.set_fixture_class :katello_system_system_groups => "Katello::SystemSystemGroup"
  self.set_fixture_class :katello_task_statuses => "Katello::TaskStatus"
  self.set_fixture_class :katello_user_notices => "Katello::UserNotice"

  def self.before_suite
    load_fixtures
    self.fixture_path = "#{Katello::Engine.root}/test/fixtures/models"
    fixtures(:all)
    @loaded_fixtures = load_fixtures
    @@admin = User.find(@loaded_fixtures['users']['admin']['id'])
    @@admin.remote_id = @@admin.login
    User.current = @@admin
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

  cached_entry = {
    :cp => Katello.config.use_cp,
    :pulp => Katello.config.use_pulp,
    :es => Katello.config.use_elasticsearch,
    :foreman => Katello.config.use_foreman
  }

  models.each do |model|
    if @@model_service_cache[model] != cached_entry
      begin
        Katello.send(:remove_const, model)
        load "#{Katello::Engine.root}/app/models/katello/#{model.underscore}.rb"
      rescue NameError
        Object.send(:remove_const, model)
        load "#{Rails.root}/app/models/#{model.underscore}.rb"
      end
      if model == 'User'
        # Ugly hack to force the model to be loaded properly
        # Without this, the glue layer functions are not available
        User.first

        # include the concern again after User reloading
        User.send :include, Katello::Concerns::UserExtensions
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
