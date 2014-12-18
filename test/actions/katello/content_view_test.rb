#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module ::Actions::Katello::ContentView
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
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
      Katello::Configuration::Node.any_instance.stubs(:use_cp).returns(true)
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
      Katello::Configuration::Node.any_instance.stubs(:use_elasticsearch).returns(true)
      content_view.expects(:save!)
      content_view.expects(:disable_auto_reindex!)
      plan_action(action, content_view)
      assert_action_planed_with(action, ::Actions::ElasticSearch::Reindex, content_view)
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

      assert_action_planed_with(action, ::Actions::Katello::ContentViewEnvironment::Destroy, cv_env,  :skip_elastic => false, :skip_repo_destroy => false, :organization_destroy => false)
    end

    it 'plans for removing a version and an environment' do
      version = Katello::ContentViewEnvironment.where(content_view_id: content_view.id,
                                                      environment_id: environment.id
                                                     ).first.content_view_version

      options = {content_view_environments: [cv_env],
                 content_view_versions: [version]
                }
      action.expects(:action_subject).with(content_view)

      plan_action(action, content_view, options)
      assert_action_planed_with(action, ::Actions::Katello::ContentViewEnvironment::Destroy, cv_env, :skip_elastic => false, :skip_repo_destroy => false, :organization_destroy => false)
      assert_action_planed_with(action, ::Actions::Katello::ContentViewVersion::Destroy, version)
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

  class IncrementalUpdatesTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::IncrementalUpdates }

    let(:content_view) do
      katello_content_views(:library_dev_view)
    end

    let(:library) do
      katello_environments(:library)
    end

    it 'plans' do
      plan_action(action, [{:content_view_version => content_view.version(library), :environments => [library]}],
                  {:errata_ids => ["FOO"]}, true, false, "BadDescription")
      assert_action_planed_with(action, ::Actions::Katello::ContentViewVersion::IncrementalUpdate, content_view.version(library), [library],
                                :content => {:errata_ids => ["FOO"]}, :resolve_dependencies => true, :description => "BadDescription")
    end
  end
end
