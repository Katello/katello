require 'katello_test_helper'

module ::Actions::Katello::ContentView
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }

    before(:all) do
      set_user
    end
  end

  class AddToEnvironmentTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::AddToEnvironment }

    let(:environment) do
      katello_environments(:library)
    end

    let(:content_view) do
      katello_content_views(:no_environment_view)
    end

    def content_view_environment
      ::Katello::ContentViewEnvironment.where(:environment_id => environment.id, :content_view_id => content_view.id).first
    end

    it 'plans' do
      content_view_environment.must_be_nil

      version = content_view.create_new_version
      action = create_and_plan_action(action_class, version, environment)
      assert_action_planed_with(action, EnvironmentCreate) do |(cve)|
        cve.environment.must_equal environment
        cve.content_view.must_equal content_view
      end
      content_view_environment.content_view_version.version.must_equal "1.0"

      version = content_view.create_new_version
      action = create_and_plan_action(action_class, version, environment)
      refute_action_planed(action, EnvironmentCreate)
      content_view_environment.content_view_version.version.must_equal "2.0"
    end
  end

  class EnvironmentCreateTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::EnvironmentCreate }

    let(:content_view_environment) do
      katello_content_view_environments(:library_default_view_environment)
    end

    it 'plans' do
      SETTINGS[:katello].stubs(:use_cp).returns(true)
      content_view_environment.expects(:save!)
      plan_action(action, content_view_environment)
      content_view = content_view_environment.content_view
      assert_action_planed_with(action,
                                ::Actions::Candlepin::Environment::Create,
                                organization_label: content_view.organization.label,
                                cp_id:              content_view_environment.cp_id,
                                name:               content_view_environment.label,
                                description:        content_view.description)
    end
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::Create }

    let(:content_view) do
      katello_content_views(:acme_default)
    end

    it 'plans' do
      content_view.expects(:save!)
      plan_action(action, content_view)
    end
  end

  class RemoveFromEnvironmentTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::RemoveFromEnvironment }

    let(:content_view) do
      katello_content_views(:library_dev_view)
    end

    let(:environment) do
      katello_environments(:dev)
    end

    it 'plans' do
      cve = Katello::ContentViewEnvironment.where(:content_view_id => content_view, :environment_id => environment).first
      Katello::ContentViewEnvironment.stubs(:where).returns([cve])

      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)

      action.expects(:action_subject).with(content_view)
      plan_action(action, content_view, environment)
      assert_action_planed_with(action, ::Actions::Katello::ContentViewEnvironment::Destroy, cve)
    end
  end

  class RemoveVersionTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::RemoveVersion }

    let(:content_view) do
      katello_content_views(:library_dev_view)
    end

    it 'fails to plan for a promoted version' do
      version = content_view.versions.first
      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)

      assert_raises(RuntimeError) do
        plan_action(action, version)
      end
    end

    it 'plans' do
      version = Katello::ContentViewVersion.create!(:major => 2,
                                                    :content_view => content_view)
      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)

      action.expects(:action_subject).with(version.content_view)
      plan_action(action, version)
      assert_action_planed_with(action, ::Actions::Katello::ContentViewVersion::Destroy, version)
    end
  end

  class RemoveTest < TestBase
    before(:all) do
      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      ::Actions::Katello::ContentView::Remove.any_instance.stubs(:task).returns(task)
      User.current = User.first
    end

    let(:action_class) { ::Actions::Katello::ContentView::Remove }

    let(:content_view) do
      katello_content_views(:library_dev_view)
    end

    let(:environment) do
      katello_environments(:dev)
    end

    let(:cv_env) do
      Katello::ContentViewEnvironment.where(content_view_id: content_view,
                                            environment_id: environment
                                           ).first
    end

    let(:library) do
      katello_environments(:library)
    end

    let(:library_cv_env) do
      Katello::ContentViewEnvironment.where(content_view_id: content_view,
                                            environment_id: library
                                           ).first
    end

    let(:default_content_view) do
      katello_content_views(:acme_default)
    end

    it 'plans for removing environments' do
      Katello::System.update_all(content_view_id: content_view.id)

      assert_raises(RuntimeError) do
        action.validate_options(content_view, [cv_env], [], {})
      end

      options = {content_view_environments: [cv_env],
                 system_content_view_id: default_content_view.id,
                 system_environment_id: library.id
                }
      action.expects(:action_subject).with(content_view)
      plan_action(action, content_view, options)

      assert_action_planed_with(action, ::Actions::Katello::ContentViewEnvironment::Destroy, cv_env,  :skip_repo_destroy => false, :organization_destroy => false)
    end

    it 'plans for removing a version and an environment' do
      version = Katello::ContentViewEnvironment.where(content_view_id: content_view.id,
                                                      environment_id: environment.id
                                                     ).first.content_view_version

      options = {content_view_environments: [cv_env, library_cv_env],
                 content_view_versions: [version]
                }
      action.expects(:action_subject).with(content_view)

      plan_action(action, content_view, options)
      assert_action_planed_with(action, ::Actions::Katello::ContentViewEnvironment::Destroy, cv_env, :skip_repo_destroy => false, :organization_destroy => false)
      assert_action_planed_with(action, ::Actions::Katello::ContentViewVersion::Destroy, version, :skip_environment_check => true, :skip_destroy_env_content => true)
    end
  end

  class UpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::Update }
    let(:content_view) { katello_content_views(:library_dev_view) }
    let(:repository) { katello_repositories(:rhel_6_x86_64) }
    let(:action) { create_action action_class }

    it 'plans' do
      action.expects(:action_subject).with(content_view)
      plan_action action, content_view, 'repository_ids' => [repository.id]
    end

    it 'raises error when validation fails' do
      ::Actions::Katello::ContentView::Update.any_instance.expects(:action_subject).with(content_view)
      proc { create_and_plan_action action_class, content_view, :name => '' }.must_raise(ActiveRecord::RecordInvalid)
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::Destroy }

    let(:content_view) do
      katello_content_views(:library_dev_view)
    end

    it 'plans' do
      view = Katello::ContentView.create!(:name => "New view",
                                          :organization => content_view.organization
                                         )
      version = Katello::ContentViewVersion.create!(:content_view => view,
                                                    :major => 1
                                                   )

      action.expects(:action_subject).with(view.reload)
      action.expects(:plan_self)
      plan_action(action, view)
      assert_action_planed_with(action, ::Actions::Katello::ContentViewVersion::Destroy, version, {})
    end
  end

  class Dynflow::Testing::DummyPlannedAction
    def new_content_view_version
    end
  end

  class CapsuleGenerateAndSyncTest < TestBase
    include Support::CapsuleSupport

    let(:action_class) { ::Actions::Katello::ContentView::CapsuleGenerateAndSync }
    let(:content_view) do
      katello_content_views(:library_dev_view)
    end

    let(:library) do
      katello_environments(:library)
    end

    before do
      capsule_content.add_lifecycle_environment(library)
    end

    it 'plans' do
      plan_action(action, content_view, library)
      assert_action_planed_with(action, ::Actions::Katello::ContentView::NodeMetadataGenerate, content_view, library)
      assert_action_planed_with(action, ::Actions::Katello::CapsuleContent::Sync, capsule_content, :content_view => content_view, :environment => library)
    end
  end

  class IncrementalUpdatesTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::IncrementalUpdates }

    let(:content_view) do
      katello_content_views(:library_dev_view)
    end

    let(:library) do
      katello_environments(:library)
    end

    let(:composite_version) do
      katello_content_view_versions(:composite_view_version_1)
    end

    it 'plans' do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_content_view_version).returns(::Katello::ContentViewVersion.first)

      plan_action(action, [{:content_view_version => content_view.version(library), :environments => [library]}], [],
                  {:errata_ids => ["FOO"]}, true, [], "BadDescription")
      assert_action_planed_with(action, ::Actions::Katello::ContentViewVersion::IncrementalUpdate, content_view.version(library), [library],
                                :content => {:errata_ids => ["FOO"]}, :resolve_dependencies => true, :description => "BadDescription")
    end

    it 'plans with composite' do
      component = composite_version.components.first
      new_version = ::Katello::ContentViewVersion.new

      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_content_view_version).returns(new_version)

      plan_action(action, [{:content_view_version => component, :environments => []}], [{:content_view_version => composite_version, :environments => [library]}],
                  {:errata_ids => ["FOO"]}, true, [], "BadDescription")
      assert_action_planed_with(action, ::Actions::Katello::ContentViewVersion::IncrementalUpdate, component, [],
                                :content => {:errata_ids => ["FOO"]}, :resolve_dependencies => true, :description => "BadDescription")
      assert_action_planed_with(action, ::Actions::Katello::ContentViewVersion::IncrementalUpdate, composite_version, [library],
                                :content => {:puppet_module_ids => nil}, :new_components => [new_version],
                                :description => "BadDescription")
    end

    it 'fails with component that does not match composite' do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_content_view_version).returns(::Katello::ContentViewVersion.first)
      assert_raises RuntimeError do
        plan_action(action, [{:content_view_version => content_view.version(library), :environments => []}], [{:content_view_version => composite_version, :environments => [library]}],
                  {:errata_ids => ["FOO"]}, true, [], "BadDescription")
      end
    end
  end
end
