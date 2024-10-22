require 'katello_test_helper'
module ::Actions::Katello::ContentView
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action) { create_action action_class }
    let(:success_task) { ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good") }
    let(:pending_task) { ForemanTasks::Task::DynflowTask.create!(state: :pending, result: "good", id: 123) }
    before(:all) do
      set_user
    end
  end

  class PublishTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::Publish }
    let(:content_view) { katello_content_views(:no_environment_view) }
    let(:repository) { katello_repositories(:fedora_17_x86_64) }
    before do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:repository_mapping).returns({})
    end
    it 'plans' do
      action.stubs(:task).returns(success_task)

      action.expects(:plan_self)
      plan_action(action, content_view)
    end

    it 'fails when planning if the cv is import only' do
      content_view = katello_content_views(:import_only_view)
      action.stubs(:task).returns(success_task)

      assert_raises(RuntimeError) do
        plan_action(action, content_view)
      end
    end

    it 'fails when planning if child repo is being acted upon' do
      content_view.repositories = [repository]
      repository.expects(:blocking_task).returns(pending_task)
      action.stubs(:task).returns(success_task)
      assert_raises(RuntimeError) do
        plan_action(action, content_view)
      end
    end

    it 'uses override_components properly' do
      action.stubs(:task).returns(success_task)
      action.expects(:include_other_components).with('mock', content_view).returns('mock')
      content_view.expects(:publish_repositories).with.returns([])
      content_view.expects(:publish_repositories).with('mock').returns([])
      plan_action action, content_view, nil, override_components: 'mock', importing: false
    end

    context 'run phase' do
      it 'creates auto-publish events for non-composite views' do
        composite_view = katello_content_views(:composite_view)
        action.stubs(:task).returns(success_task)

        FactoryBot.create(:katello_content_view_component,
                          latest: true,
                          composite_content_view: composite_view,
                          content_view: content_view)

        plan_action action, content_view
        run_action action

        event = Katello::Event.find_by(event_type: Katello::Events::AutoPublishCompositeView::EVENT_TYPE, object_id: composite_view.id)
        version = content_view.versions.last

        assert_equal event.metadata[:triggered_by], version.id
        assert_equal event.metadata[:description], "Auto Publish - Triggered by '#{version.name}'"
      end

      it 'does nothing for non-composite view' do
        action.stubs(:task).returns(success_task)

        plan_action action, katello_content_views(:no_environment_view)
        run_action action

        assert_empty Katello::Event.all
      end
    end

    context 'finalize phase' do
      it 'updates errata counts and status' do
        content_facet = katello_content_facets(:content_facet_two)
        action.stubs(:input).returns(
          content_view_version_id: content_facet.content_view_environments.first.content_view_version.id,
          content_view_id: content_facet.content_view_environments.first.content_view_id,
          environment_id: content_facet.content_view_environments.first.environment_id,
          history_id: Katello::ContentViewHistory.first.id
        )
        Katello::Host::ContentFacet.any_instance.expects(:update_applicability_counts)
        Katello::Host::ContentFacet.any_instance.expects(:update_errata_status)
        action.finalize
      end
    end
  end

  class RefreshRollingRepoTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::RefreshRollingRepo }
    let(:content_view) { katello_content_views(:rolling_view) }
    let(:repository_deb) { katello_repositories(:debian_10_amd64) }
    let(:library) { katello_environments(:library) }
    let(:clone_deb) do
      FactoryBot.create :katello_repository,
                        root: repository_deb.root,
                        library_instance: repository_deb,
                        content_view_version: content_view.versions.first,
                        environment: library
    end

    before do
      repository_deb.version_href = 'foo'
      repository_deb.publication_href = 'bar'
      repository_deb.save!
      clone_deb.save!
    end

    it 'plans' do
      action.stubs(:task).returns(success_task)
      refute_equal repository_deb.version_href, clone_deb.version_href

      plan_action(action, clone_deb, true)

      assert_action_planned_with action, ::Actions::Pulp3::Repository::RefreshDistribution, clone_deb, SmartProxy.pulp_primary
      assert_action_planned_with action, ::Actions::Katello::Repository::IndexContent, id: clone_deb.id, source_repository_id: repository_deb.id
      assert_action_planned_with action, ::Actions::Katello::Applicability::Repository::Regenerate, repo_ids: [clone_deb.id]
    end

    it 'triggers with upload_files' do
      upload_action = create_action ::Actions::Katello::Repository::UploadFiles
      upload_action.stubs(:task).returns(success_task)
      upload_action.stubs(:prepare_tmp_files).returns([{path: 'some/path'}])

      plan_action(upload_action, repository_deb, [{path: 'nowhere'}])

      assert_action_planned_with upload_action, action_class, clone_deb, true
    end

    it 'triggers with import_upload' do
      import_action = create_action ::Actions::Katello::Repository::ImportUpload
      import_action.stubs(:task).returns(success_task)
      file = File.join(::Katello::Engine.root, 'test', 'fixtures', 'files', 'frigg_1.0_ppc64.deb')
      #action.expects(:action_subject).with(custom_repository)

      plan_action import_action, repository_deb, [{:path => file, :filename => 'frigg_1.0_ppc64.deb'}]

      assert_action_planned_with import_action, action_class, clone_deb, true
    end

    it 'updates pulp_hrefs' do
      last_changed = DateTime.new(2024, 12, 2.5)
      DateTime.stubs(:now).returns(last_changed)
      action_class.any_instance.expects(:plan_action).at_least(3)

      ForemanTasks.sync_task(action_class, clone_deb, true)

      clone_deb.reload
      assert_equal repository_deb.version_href, clone_deb.version_href
      assert_equal repository_deb.publication_href, clone_deb.publication_href
      assert_equal repository_deb.content_id, clone_deb.content_id
      assert_equal last_changed, clone_deb.last_contents_changed
    end
  end

  class SyncRepositoryRefreshRollingRepoTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Sync }
    let(:content_view) { katello_content_views(:rolling_view) }
    let(:repository_rpm) { katello_repositories(:fedora_17_x86_64) }
    let(:library) { katello_environments(:library) }
    let(:clone_rpm) do
      FactoryBot.create :katello_repository,
                        root: repository_rpm.root,
                        library_instance: repository_rpm,
                        content_view_version: content_view.versions.first,
                        environment: library
    end

    before do
      repository_rpm.version_href = 'foo'
      repository_rpm.publication_href = 'bar'
      repository_rpm.save!
      clone_rpm.save!
    end

    it 'triggers async RefreshRollingRepo' do
      action.stubs(:input).returns(
        id: clone_rpm.id,
        contents_changed: true
      )
      Katello::Repository.any_instance.expects(:clear_smart_proxy_sync_histories)
      ForemanTasks.expects(:async_task).with(::Actions::Katello::ContentView::RefreshRollingRepo,
                                            clone_rpm, true)
      ForemanTasks.expects(:async_task).with(::Actions::Katello::Repository::CapsuleSync, clone_rpm)
      action.finalize
    end
  end

  class AddRollingRepoCloneTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::AddRollingRepoClone }
    let(:content_view) { katello_content_views(:rolling_view) }
    let(:repository_rpm) { katello_repositories(:fedora_17_x86_64) }
    let(:repository_deb) { katello_repositories(:debian_10_amd64) }
    let(:library) { katello_environments(:library) }
    let(:clone_rpm) do
      FactoryBot.create :katello_repository,
                      root: repository_rpm.root,
                      content_view_version: content_view.versions.first,
                      environment: library
    end
    let(:clone_deb) do
      FactoryBot.create :katello_repository,
                      root: repository_deb.root,
                      content_view_version: content_view.versions.first,
                      environment: library
    end
    let(:cv_env) { content_view.content_view_environment(library) }

    before do
      [repository_rpm, repository_deb].each do |repository|
        repository.version_href = 'foo'
        repository.publication_href = 'bar'
        repository.save!
      end
    end

    it 'plans multiple' do
      action.stubs(:task).returns(success_task)

      Katello::Repository.any_instance.expects(:build_clone).returns(clone_deb)
      Katello::Repository.any_instance.expects(:build_clone).returns(clone_rpm)
      plan_action(action, content_view, [repository_rpm.id, repository_deb.id])

      assert_action_planned_with action, ::Actions::Katello::ContentView::RefreshRollingRepo, clone_rpm, false
      assert_action_planned_with action, ::Actions::Katello::ContentView::RefreshRollingRepo, clone_deb, false

      assert_action_planned_with action, ::Actions::Candlepin::Environment::AddContentToEnvironment,
                                 view_env_cp_id: cv_env.cp_id, content_id: repository_rpm.content_id
      assert_action_planned_with action, ::Actions::Candlepin::Environment::AddContentToEnvironment,
                                 view_env_cp_id: cv_env.cp_id, content_id: repository_deb.content_id
    end

    it 'plan refresh for existing' do
      clone_deb.library_instance = repository_deb
      clone_deb.version_href = 'some_version'
      clone_deb.publication_href = 'some_publication'
      clone_deb.save!

      refute_equal repository_deb.version_href, clone_deb.version_href
      refute_equal repository_deb.publication_href, clone_deb.publication_href
      # double-add
      plan_action(action, content_view, [repository_deb.id])

      assert_equal 1, content_view.get_repo_clone(library, repository_deb).count
      assert_action_planned_with action, ::Actions::Katello::ContentView::RefreshRollingRepo, clone_deb, false
      assert_action_planned_with action, ::Actions::Candlepin::Environment::AddContentToEnvironment,
                                 view_env_cp_id: cv_env.cp_id, content_id: repository_deb.content_id
    end

    it 'plans nothing' do
      plan_action(action, content_view, [])

      refute_action_planned action, ::Actions::Katello::ContentView::RefreshRollingRepo
      refute_action_planned action, ::Actions::Candlepin::Environment::AddContentToEnvironment
    end
  end

  class RemoveRollingRepoCloneTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::RemoveRollingRepoClone }
    let(:content_view) { katello_content_views(:rolling_view) }
    let(:repository_rpm) { katello_repositories(:fedora_17_x86_64) }
    let(:repository_deb) { katello_repositories(:debian_10_amd64) }
    let(:library) { katello_environments(:library) }
    let(:clone_rpm) do
      FactoryBot.create :katello_repository,
                      root: repository_rpm.root,
                      library_instance: repository_rpm,
                      content_view_version: content_view.versions.first,
                      environment: library
    end
    let(:clone_deb) do
      FactoryBot.create :katello_repository,
                      root: repository_deb.root,
                      library_instance: repository_deb,
                      content_view_version: content_view.versions.first,
                      environment: library
    end
    let(:primary) { SmartProxy.pulp_primary }

    before do
      [repository_rpm, repository_deb].each do |repository|
        repository.version_href = 'foo'
        repository.publication_href = 'bar'
        repository.save!
      end
    end

    it 'plans remove multiple' do
      clone_rpm.save!
      clone_deb.save!

      plan_action(action, content_view, [repository_rpm.id, repository_deb.id])

      assert_action_planned_with action, ::Actions::Pulp3::Repository::DeleteDistributions, clone_rpm.id, primary
      assert_action_planned_with action, ::Actions::Pulp3::Repository::DeleteDistributions, clone_deb.id, primary

      cv_env = content_view.content_view_environment(library)
      assert_action_planned_with action, ::Actions::Candlepin::Environment::SetContent, content_view, library, cv_env
    end

    it 'plan ignores gone repo' do
      clone_rpm.destroy

      plan_action(action, content_view, [repository_rpm.id])

      refute_action_planned action, ::Actions::Pulp3::Repository::DeleteDistributions

      cv_env = content_view.content_view_environment(library)
      assert_action_planned_with action, ::Actions::Candlepin::Environment::SetContent, content_view, library, cv_env
    end

    it 'plans nothing' do
      plan_action(action, content_view, [])
      refute_action_planned action, ::Actions::Pulp3::Repository::DeleteDistributions
      assert_action_planned action, ::Actions::Candlepin::Environment::SetContent
    end
  end

  class PromoteToEnvironmentTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::PromoteToEnvironment }

    let(:environment) do
      katello_environments(:library)
    end

    let(:content_view_version) do
      katello_content_views(:no_environment_view).create_new_version
    end

    it 'plans' do
      assert_empty content_view_version.history
      action.stubs(:task).returns(success_task)

      plan_action(action, content_view_version, environment, 'description')

      refute_empty content_view_version.history
      refute_action_planned(action, Actions::Katello::ContentView::CapsuleSync)
    end

    it 'plans for incremental update' do
      action.stubs(:task).returns(success_task)
      action.expects(:sync_proxies?).returns(true)

      plan_action(action, content_view_version, environment, 'description', true)

      refute_empty content_view_version.history
      assert_action_planned(action, Actions::Katello::ContentView::CapsuleSync)
    end

    context 'finalize phase' do
      it 'updates errata counts and status' do
        content_facet = katello_content_facets(:content_facet_two)
        action.stubs(:input).returns(
          content_view_id: content_facet.content_view_environments.first.content_view_id,
          environment_id: content_facet.content_view_environments.first.environment_id,
          history_id: Katello::ContentViewHistory.first.id
        )
        Katello::Host::ContentFacet.any_instance.expects(:update_applicability_counts)
        Katello::Host::ContentFacet.any_instance.expects(:update_errata_status)
        action.finalize
      end
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
      refute content_view_environment
      ::Katello::ContentViewEnvironment.any_instance.expects(:exists_in_candlepin?).returns(false)
      ::Katello::Resources::Candlepin::Environment.expects(:create).once.returns

      version = content_view.create_new_version
      create_and_plan_action(action_class, version, environment)
      assert_equal '1.0', content_view_environment.content_view_version.version

      ::Katello::ContentViewEnvironment.any_instance.expects(:exists_in_candlepin?).returns(true)
      version = content_view.create_new_version
      create_and_plan_action(action_class, version, environment)
      assert_equal '2.0', content_view_environment.content_view_version.version
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
      cve.hosts.each { |host| host.content_facet.destroy }
      Katello::ContentViewEnvironment.stubs(:where).returns([cve])

      action.stubs(:task).returns(success_task)

      action.expects(:action_subject).with(content_view)
      plan_action(action, content_view, environment)
      assert_action_planned_with(action, ::Actions::Katello::ContentViewEnvironment::Destroy, cve)
    end
  end

  class RemoveVersionTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::RemoveVersion }

    let(:content_view) do
      katello_content_views(:library_dev_view)
    end

    it 'fails to plan for a promoted version' do
      version = content_view.versions.first
      action.stubs(:task).returns(success_task)

      assert_raises(RuntimeError) do
        plan_action(action, version)
      end
    end

    it 'plans' do
      version = Katello::ContentViewVersion.create!(:major => 2,
                                                    :content_view => content_view)
      action.stubs(:task).returns(success_task)

      action.expects(:action_subject).with(version.content_view)
      plan_action(action, version)
      assert_action_planned_with(action, ::Actions::Katello::ContentViewVersion::Destroy, version)
    end
  end

  class RemoveTest < TestBase
    include Support::CapsuleSupport
    before(:all) do
      action.stubs(:task).returns(success_task)
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
      assert_raises(RuntimeError) do
        action.validate_options(content_view, [cv_env], [], {})
      end

      options = {content_view_environments: [cv_env],
                 system_content_view_id: default_content_view.id,
                 system_environment_id: library.id,
                }
      action.expects(:action_subject).with(content_view)
      plan_action(action, content_view, options)

      assert_action_planned_with(action, ::Actions::Katello::ContentViewEnvironment::Destroy, cv_env, :skip_repo_destroy => false, :organization_destroy => false)
    end

    it 'plans for removing a version and an environment' do
      cve = Katello::ContentViewEnvironment.where(content_view_id: content_view.id,
                                                      environment_id: environment.id
                                                 ).first
      version = cve.content_view_version
      cve.hosts.each { |h| h.content_facet.destroy }
      options = {content_view_environments: [cv_env, library_cv_env],
                 content_view_versions: [version],
                }
      action.expects(:action_subject).with(content_view)

      plan_action(action, content_view, options)
      assert_action_planned_with(action, ::Actions::Katello::ContentViewEnvironment::Destroy, cv_env, :skip_repo_destroy => false, :organization_destroy => false)
      assert_action_planned_with(action, ::Actions::Katello::ContentViewVersion::Destroy, version, :skip_environment_check => true, :skip_destroy_env_content => true)
    end

    it 'plans deleting all CV env and versions and removing repository references with destroy_content_view param' do
      smart_proxy_service_1 = new_capsule_content(:three)
      ::SmartProxy.stubs(:pulp_primary).returns(smart_proxy_service_1.smart_proxy)
      cve = Katello::ContentViewEnvironment.where(content_view_id: content_view.id,
                                                  environment_id: environment.id).first
      cve.hosts.each { |h| h.content_facet.destroy }
      options = {content_view_environments: content_view.content_view_environments,
                 content_view_versions: content_view.versions,
                 destroy_content_view: true,
      }
      action.expects(:action_subject).with(content_view)

      plan_action(action, content_view, options)
      content_view.content_view_environments.each do |cvenv|
        assert_action_planned_with(action, ::Actions::Katello::ContentViewEnvironment::Destroy, cvenv, :skip_repo_destroy => false, :organization_destroy => false)
      end
      content_view.versions.each do |cv_version|
        assert_action_planned_with(action, ::Actions::Katello::ContentViewVersion::Destroy, cv_version, :skip_environment_check => true, :skip_destroy_env_content => true)
      end
      assert_action_planned_with(action, ::Actions::Pulp3::ContentView::DeleteRepositoryReferences, content_view, smart_proxy_service_1.smart_proxy)
    end

    context 'organization destroy' do
      it 'works' do
        ::Hostgroup.create!(name: 'foo',
                            content_view: content_view,
                            lifecycle_environment: environment)
        options = { organization_destroy: true }
        action.expects(:action_subject).with(content_view)
        refute_empty content_view.hosts.first.content_facet.content_facet_errata
        plan_action(action, content_view, options)
      end
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

    it 'deletes old filter rules' do
      content_view.repositories << repository
      module_stream = katello_module_streams(:river)
      erratum = repository.errata.find_by(pulp_id: 'partylikeits1999')
      package_group = katello_package_groups(:server_pg)

      repository.module_streams << module_stream
      repository.package_groups << package_group

      module_stream_filter = ::Katello::ContentViewModuleStreamFilter.create(name: 'module filter', content_view_id: content_view.id)
      errata_filter = ::Katello::ContentViewErratumFilter.create(name: 'errata filter', content_view_id: content_view.id)
      package_group_filter = ::Katello::ContentViewPackageGroupFilter.create(name: 'package group filter', content_view_id: content_view.id)

      module_stream_rule = ::Katello::ContentViewModuleStreamFilterRule.create(content_view_filter_id: module_stream_filter.id, module_stream_id: module_stream.id)
      errata_rule = ::Katello::ContentViewErratumFilterRule.create(content_view_filter_id: errata_filter.id, errata_id: erratum.errata_id)
      package_group_rule = ::Katello::ContentViewPackageGroupFilterRule.create(content_view_filter_id: package_group_filter.id, uuid: package_group.pulp_id)

      action.expects(:action_subject).with(content_view)
      plan_action action, content_view, 'repository_ids' => []

      assert_raises ActiveRecord::RecordNotFound do
        module_stream_rule.reload
      end

      assert_raises ActiveRecord::RecordNotFound do
        errata_rule.reload
      end

      assert_raises ActiveRecord::RecordNotFound do
        package_group_rule.reload
      end
    end

    it 'raises error when validation fails' do
      ::Actions::Katello::ContentView::Update.any_instance.expects(:action_subject).with(content_view)
      assert_raises(ActiveRecord::RecordInvalid) { create_and_plan_action action_class, content_view, :name => '' }
    end
  end

  class UpdateRollingTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentView::Update }
    let(:add_rolling_repo_action_class) { ::Actions::Katello::ContentView::AddRollingRepoClone }
    let(:remove_rolling_repo_action_class) { ::Actions::Katello::ContentView::RemoveRollingRepoClone }
    let(:content_view) { katello_content_views(:rolling_view) }
    let(:repository) { katello_repositories(:rhel_6_x86_64) }
    let(:action) { create_action action_class }

    it 'plans add/remove repo' do
      action.expects(:action_subject).with(content_view)
      old_repo_ids = content_view.repository_ids

      plan_action action, content_view, 'repository_ids' => [repository.id]

      assert_action_planned_with action, add_rolling_repo_action_class, content_view, [repository.id]
      assert_action_planned_with action, remove_rolling_repo_action_class, content_view, old_repo_ids
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
      assert_action_planned_with(action, ::Actions::Katello::ContentViewVersion::Destroy, version, {})
    end
  end

  class Dynflow::Testing::DummyPlannedAction
    def new_content_view_version
    end
  end

  class CapsuleSyncTest < TestBase
    include Support::CapsuleSupport

    let(:action_class) { ::Actions::Katello::ContentView::CapsuleSync }
    let(:content_view) do
      katello_content_views(:library_dev_view)
    end

    let(:library) do
      katello_environments(:library)
    end

    it 'plans' do
      Location.current = taxonomies(:location2)
      smart_proxy_service_1 = new_capsule_content(:three)
      smart_proxy_service_2 = new_capsule_content(:four)
      smart_proxy_service_1.smart_proxy.add_lifecycle_environment(library)
      smart_proxy_service_2.smart_proxy.add_lifecycle_environment(library)

      plan_action(action, content_view, library)
      assert_action_planned_with(action, ::Actions::BulkAction, ::Actions::Katello::CapsuleContent::Sync,
                                 [smart_proxy_service_1.smart_proxy, smart_proxy_service_2.smart_proxy].sort,
                                 :content_view_id => content_view.id,
                                 :environment_id => library.id,
                                 :skip_content_counts_update => true)
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
      assert_action_planned_with(action, ::Actions::Katello::ContentViewVersion::IncrementalUpdate, content_view.version(library), [library],
                                :content => {:errata_ids => ["FOO"]}, :resolve_dependencies => true, :description => "BadDescription")
    end

    it 'plans with composite' do
      component = composite_version.components.first
      new_version = ::Katello::ContentViewVersion.new
      proxy = SmartProxy.pulp_primary
      SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)

      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_content_view_version).returns(new_version)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_content_view_version_id).returns(1)

      plan_action(action, [{:content_view_version => component, :environments => []}], [{:content_view_version => composite_version, :environments => [library]}],
                  {:errata_ids => ["FOO"]}, true, [], "BadDescription")
      assert_action_planned_with(action, ::Actions::Katello::ContentViewVersion::IncrementalUpdate, component, [],
                                :content => {:errata_ids => ["FOO"]}, :resolve_dependencies => true, :description => "BadDescription")
      assert_action_planned_with(action, ::Actions::Katello::ContentViewVersion::IncrementalUpdate, composite_version, [library],
                                :new_components => [new_version],
                                :description => "BadDescription")
    end

    it 'fails with component that does not match composite' do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_content_view_version).returns(::Katello::ContentViewVersion.first)
      assert_raises RuntimeError do
        plan_action(action, [{:content_view_version => content_view.version(library), :environments => []}], [{:content_view_version => composite_version, :environments => [library]}],
                  {:errata_ids => ["FOO"]}, true, [], "BadDescription")
      end
    end

    it 'generates correct message' do
      data = {:version_outputs =>
               [{:version_id => 1,
                 :output =>
                  {:added_units =>
                    {:erratum => ["RHEA-FOO"],
                     :rpm =>
                      ["shark-0.1-1.noarch",
                       "penguin-0.9.1-1.noarch",
                       "walrus-5.21-1.noarch"],
                    },
                  },
                }],
              }
      total_count = action.total_counts(data)
      assert_equal total_count[:errata_count], 1
      assert_equal total_count[:rpm_count], 3
      assert_equal total_count[:content_view_count], 1

      assert_equal action.content_output(total_count), "with 3 Package(s), and 1 Errata"
    end
  end
end
