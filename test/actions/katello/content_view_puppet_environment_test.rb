require 'katello_test_helper'

module ::Actions::Katello::ContentViewPuppetEnvironment
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods
    include Support::CapsuleSupport

    let(:puppet_env) { katello_content_view_puppet_environments(:library_view_puppet_environment) }

    setup do
      set_default_location
    end
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewPuppetEnvironment::Create }
    let(:action) { create_action action_class }

    it 'plans' do
      default_capsule = mock
      default_capsule.expects(:puppet_path).returns('/etc/puppet/environments')
      SmartProxy.expects(:default_capsule).returns(default_capsule)
      puppet_env.expects(:save!)
      action.expects(:action_subject).with(puppet_env)

      plan_action action, puppet_env
      assert_action_planed action, ::Actions::Pulp::Repository::Create
      refute_action_planed action, ::Actions::Katello::Product::ContentCreate
    end
  end

  class ClearTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewPuppetEnvironment::Clear }
    let(:action) { create_action action_class }

    it 'plans' do
      plan_action action, puppet_env
      assert_action_planed_with action, ::Actions::Pulp::Repository::RemovePuppetModule, :pulp_id => puppet_env.pulp_id
    end
  end

  class CloneContentTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewPuppetEnvironment::CloneContent }
    let(:action) { create_action action_class }
    let(:source_repo) { katello_content_view_puppet_environments(:dev_view_puppet_environment) }
    let(:module_id) { 'bcd' }
    it 'plan' do
      plan_action action, puppet_env, source_repo.pulp_id => [module_id]
      assert_action_planed_with action, ::Actions::Pulp::Repository::CopyPuppetModule, :source_pulp_id => source_repo.pulp_id,
                                                                                       :target_pulp_id => puppet_env.pulp_id,
                                                                                       :clauses => { 'unit_id' => { "$in" => [module_id] } }
    end
  end

  class CloneToEnvironmentTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewPuppetEnvironment::Clone }
    let(:action) { create_action action_class }
    let(:dev) { katello_environments(:dev) }
    let(:dev_puppet_env) { katello_content_view_puppet_environments(:dev_view_puppet_environment) }

    let(:source_puppet_env) { katello_content_view_puppet_environments(:archive_view_puppet_environment) }

    it 'plans with existing puppet environment' do
      ::Katello::Repository.expects(:needs_distributor_updates).returns([{}])
      plan_action action, puppet_env.content_view_version, :environment => dev

      assert_action_planed_with action, ::Actions::Katello::ContentViewPuppetEnvironment::Clear, dev_puppet_env
      refute_action_planed action, ::Actions::Katello::ContentViewPuppetEnvironment::Create
      assert_action_planed_with action, ::Actions::Pulp::Repository::CopyPuppetModule,
                                source_pulp_id: source_puppet_env.pulp_id,
                                target_pulp_id: dev_puppet_env.pulp_id,
                                criteria: nil
      assert_action_planed_with action, ::Actions::Katello::Repository::MetadataGenerate, dev_puppet_env
      refute_nil dev_puppet_env.reload.puppet_environment
    end

    it 'plans without existing cv puppet environment' do
      dev_puppet_env.puppet_modules.delete_all
      dev_puppet_env.delete

      plan_action action, puppet_env.content_view_version, :environment => dev

      assert_action_planed action, ::Actions::Katello::ContentViewPuppetEnvironment::Create
      refute_action_planed action, ::Actions::Katello::ContentViewPuppetEnvironment::Clear
      assert_action_planed action, ::Actions::Pulp::Repository::CopyPuppetModule
      assert_action_planed action, ::Actions::Katello::Repository::MetadataGenerate
    end

    it 'plans with uneeded existing cv puppet environment' do
      dev_puppet_env.update_attribute(:puppet_environment_id, nil)

      plan_action action, puppet_env.content_view_version, :environment => dev, :puppet_modules_present => false

      assert_action_planed action, ::Actions::Katello::ContentViewPuppetEnvironment::Destroy
      refute_action_planed action, ::Actions::Pulp::Repository::CopyPuppetModule
      refute_action_planed action, ::Actions::Katello::Repository::MetadataGenerate
    end

    it 'does not plan things when cvep does not already exist and no puppet modules' do
      dev_puppet_env.puppet_modules.delete_all
      dev_puppet_env.delete

      plan_action action, puppet_env.content_view_version, :environment => dev, :puppet_modules_present => false
      refute_action_planed action, ::Actions::Katello::ContentViewPuppetEnvironment::Create
      refute_action_planed action, ::Actions::Pulp::Repository::CopyPuppetModule
      refute_action_planed action, ::Actions::Katello::Repository::MetadataGenerate
    end

    it 'plans repository refresh when distributor config changes' do
      ::Katello::Repository.expects(:needs_distributor_updates).returns([{}])
      plan_action action, puppet_env.content_view_version, :environment => dev

      assert_action_planed action, ::Actions::Pulp::Repository::Refresh
    end
  end

  class CreateForVersionTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewPuppetEnvironment::CreateForVersion }
    let(:action) { create_action action_class }
    let(:version) { katello_content_view_versions(:library_view_version_2) }
    let(:module_map) { {'some_source_repo' => ['asdf']} }

    it 'plan' do
      new_puppet_env = ::Katello::ContentViewPuppetEnvironment.new
      ::Katello::ContentViewPuppetEnvironment.stubs(:new).returns(new_puppet_env)
      version.content_view_puppet_environments.destroy_all
      assert_empty version.content_view_puppet_environments

      version.content_view.stubs(:computed_module_ids_by_repoid).returns(module_map)
      plan_action action, version

      assert_action_planed_with action, ::Actions::Katello::ContentViewPuppetEnvironment::Create, new_puppet_env, true
      assert_action_planed_with action, ::Actions::Katello::ContentViewPuppetEnvironment::CloneContent, new_puppet_env, module_map
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewPuppetEnvironment::Destroy }
    let(:action) { create_action action_class }
    let(:puppet_env) { katello_content_view_puppet_environments(:dev_view_puppet_environment) }

    it 'plans' do
      action.expects(:action_subject).with(puppet_env)
      action.expects(:plan_self)
      plan_action action, puppet_env

      assert_action_planed_with action, ::Actions::Pulp::Repository::Destroy, pulp_id: puppet_env.pulp_id
    end
  end
end
