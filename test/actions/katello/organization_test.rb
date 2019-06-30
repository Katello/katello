require 'katello_test_helper'

module ::Actions::Katello::Organization
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryBot::Syntax::Methods

    let(:action) { create_action action_class }

    let(:organization) do
      build(:katello_organization, :acme_corporation, :with_library)
    end

    before do
      set_user
    end

    def stub_action_locking!(action)
      action.stubs(:link!)
      action.stubs(:lock!)
      action.stubs(:exclusive_lock!)
    end

    def except_notification(action, action_result)
      action.stubs(:result).returns(action_result)

      task = stub(:id => 1, :external_id => action.id)
      ::ForemanTasks::Task::DynflowTask.stubs(:where).with(:external_id => action.id).returns([task])

      yield(task)

      action.send_notification(action)
    end
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::Organization::Create }

    it 'plans' do
      organization.expects(:create_library)
      organization.expects(:create_anonymous_provider)
      organization.expects(:create_redhat_provider)
      organization.expects(:save!)
      action.stubs(:action_subject).with(organization, any_parameters)
      plan_action(action, organization)
      assert_action_planed_with(action,
                                ::Actions::Candlepin::Owner::Create,
                                label:  organization.label,
                                name: organization.name)

      assert_action_planed_with(action,
                                ::Actions::Katello::Environment::LibraryCreate,
                                organization.library)
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::Organization::Destroy }
    let(:action) { create_action action_class }

    let(:organization) { stub }

    it 'plans' do
      stub_remote_user
      env = stub

      action.stubs(:action_subject).with(organization)
      default_view = stub(:content_view_environments => [])
      library = stub(:destroy! => true)

      organization.expects(:label).returns("ACME_Corporation")
      organization.expects(:validate_destroy).returns([])
      organization.expects(:products).returns([])
      where_clause = mock
      where_clause.expects(:where).returns([])
      ::Host.expects(:unscoped).returns(where_clause)
      organization.expects(:activation_keys).returns([])
      organization.expects(:content_views).returns(stub(:non_default => []))
      organization.expects(:default_content_view).twice.returns(default_view)
      organization.expects(:promotion_paths).returns([[env]])
      organization.expects(:providers).returns([])
      organization.expects(:library).returns(library)

      plan_action(action, organization)

      assert_action_planed_with(action,
                                ::Actions::Candlepin::Owner::Destroy,
                                label: "ACME_Corporation")
      assert_action_planed_with(action, ::Actions::Katello::ContentView::Destroy, default_view, :check_ready_to_destroy => false, :organization_destroy => true)
      assert_action_planed_with(action, ::Actions::Katello::Environment::Destroy, env, :skip_repo_destroy => true, :organization_destroy => true)
    end
  end

  class AutoAttachSubscriptionsTest < TestBase
    let(:action_class) { ::Actions::Katello::Organization::AutoAttachSubscriptions }

    it 'plans' do
      action.stubs(:action_subject).with(organization)
      plan_action(action, organization)
      assert_action_planed_with(action,
                                ::Actions::Candlepin::Owner::AutoAttach,
                                label: organization.label)
    end
  end

  class ManifestRefreshTest < TestBase
    let(:action_class) { ::Actions::Katello::Organization::ManifestRefresh }

    it 'plans' do
      acme_org = taxonomies(:empty_organization)
      upstream = {}
      rhel7 = katello_repositories(:rhel_7_x86_64)
      acme_org.stubs(:owner_details).returns({})
      acme_org.products.stubs(:redhat).returns([rhel7.product])
      action.stubs(:action_subject).with(acme_org)
      action.stubs(:rand).returns('1234')
      plan_action(action, acme_org)

      found = assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::UpstreamUpdate,
                                 organization_id: acme_org.id,
                                 upstream: upstream)

      found = assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::UpstreamExport,
                                 organization_id: acme_org.id,
                                 upstream: upstream,
                                 path: "/tmp/1234.zip",
                                 dependency: found.first.output
                                        )
      found = assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::Import,
                                 label: acme_org.label,
                                 path: "/tmp/1234.zip",
                                 dependency: found.first.output
                                        )
      found = assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::ImportProducts,
                                 organization_id: acme_org.id,
                                 dependency: found.first.output
                                        )
      assert_action_planned_with(action,
                                 ::Actions::Katello::Repository::RefreshRepository,
                                 rhel7,
                                 dependency: found.first.output
                                )
    end

    it 'plans & create audit record for organization with comment manifest refreshed' do
      acme_org = get_organization(:empty_organization)
      rhel7 = katello_repositories(:rhel_7_x86_64)
      acme_org.stubs(:owner_details).returns({})
      acme_org.products.stubs(:redhat).returns([rhel7.product])
      action.stubs(:rand).returns('1234')

      stub_action_locking!(action)

      plan_action(action, acme_org)
      assert_difference 'Audit.count', 1 do
        finalize_action(action)
      end
    end

    describe 'notifications' do
      let(:acme_org) do
        org = get_organization(:empty_organization)
        org.stubs(:owner_details).returns({})
        org
      end

      it 'sends a success notification' do
        action.stubs(:rand).returns('1234')
        stub_action_locking!(action)
        plan_action(action, acme_org)

        except_notification(action, :success) do |_task|
          ::Katello::UINotifications::Subscriptions::ManifestRefreshSuccess.expects(:deliver!).with(acme_org)
        end
      end

      it 'sends a failure notification when the task ends with warning' do
        action.stubs(:rand).returns('1234')
        stub_action_locking!(action)
        plan_action(action, acme_org)

        except_notification(action, :warning) do |task|
          ::Katello::UINotifications::Subscriptions::ManifestRefreshError.expects(:deliver!).with(
            :subject => acme_org,
            :task => task
          )
        end
      end

      it 'sends a failure notification when the task was cancelled' do
        action.stubs(:rand).returns('1234')
        stub_action_locking!(action)
        plan_action(action, acme_org)

        except_notification(action, :cancelled) do |task|
          ::Katello::UINotifications::Subscriptions::ManifestRefreshError.expects(:deliver!).with(
            :subject => acme_org,
            :task => task
          )
        end
      end

      it 'sends a failure notification when the task ends with error' do
        action.stubs(:rand).returns('1234')
        stub_action_locking!(action)
        plan_action(action, acme_org)

        except_notification(action, :error) do |task|
          ::Katello::UINotifications::Subscriptions::ManifestRefreshError.expects(:deliver!).with(
            :subject => acme_org,
            :task => task
          )
        end
      end
    end
  end

  class ManifestImportTest < TestBase
    let(:action_class) { ::Actions::Katello::Organization::ManifestImport }

    it 'plans' do
      rhel7 = katello_repositories(:rhel_7_x86_64)
      organization.products.stubs(:redhat).returns([rhel7.product])
      action.stubs(:action_subject).with(organization)
      plan_action(action, organization, '/tmp/1234.zip', false)

      assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::Import,
                                 label: organization.label,
                                 path: "/tmp/1234.zip",
                                 force: false
                                )
      assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::ImportProducts,
                                 organization_id: organization.id
                                )
      assert_action_planned_with(action,
                                 ::Actions::Katello::Repository::RefreshRepository,
                                 rhel7
                                )
    end

    it 'plans & create audit record for organization with comment manifest imported' do
      acme_org = get_organization(:empty_organization)
      rhel7 = katello_repositories(:rhel_7_x86_64)
      acme_org.products.stubs(:redhat).returns([rhel7.product])

      stub_action_locking!(action)
      plan_action(action, acme_org, '/tmp/1234.zip', false)
      assert_difference 'Audit.count', 1 do
        finalize_action(action)
      end
    end

    describe 'notifications' do
      let(:acme_org) { get_organization(:empty_organization) }
      let(:manifest_path) { '/tmp/1234.zip' }

      it 'sends a success notification' do
        stub_action_locking!(action)
        plan_action(action, acme_org, manifest_path, false)

        except_notification(action, :success) do |_task|
          ::Katello::UINotifications::Subscriptions::ManifestImportSuccess.expects(:deliver!).with(acme_org)
        end
      end

      it 'sends a failure notification when the task ends with warning' do
        stub_action_locking!(action)
        plan_action(action, acme_org, manifest_path, false)

        except_notification(action, :warning) do |task|
          ::Katello::UINotifications::Subscriptions::ManifestImportError.expects(:deliver!).with(
            :subject => acme_org,
            :task => task
          )
        end
      end

      it 'sends a failure notification when the task was cancelled' do
        stub_action_locking!(action)
        plan_action(action, acme_org, manifest_path, false)

        except_notification(action, :cancelled) do |task|
          ::Katello::UINotifications::Subscriptions::ManifestImportError.expects(:deliver!).with(
            :subject => acme_org,
            :task => task
          )
        end
      end

      it 'sends a failure notification when the task ends with error' do
        stub_action_locking!(action)
        plan_action(action, acme_org, manifest_path, false)

        except_notification(action, :error) do |task|
          ::Katello::UINotifications::Subscriptions::ManifestImportError.expects(:deliver!).with(
            :subject => acme_org,
            :task => task
          )
        end
      end
    end
  end

  class ManifestDeleteTest < TestBase
    let(:action_class) { ::Actions::Katello::Organization::ManifestDelete }

    it 'plans' do
      rhel7 = katello_repositories(:rhel_7_x86_64)
      organization.products.stubs(:redhat).returns([rhel7.product])
      action.stubs(:action_subject).with(organization)
      plan_action(action, organization)

      assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::DestroyImports,
                                 label: organization.label
                                )
      assert_action_planned_with(action,
                                 ::Actions::Katello::Repository::RefreshRepository,
                                 rhel7
                                )
    end

    it 'creates audit record for organization after manifest deletion' do
      acme_org = get_organization(:empty_organization)
      rhel7 = katello_repositories(:rhel_7_x86_64)
      acme_org.products.stubs(:redhat).returns([rhel7.product])

      stub_action_locking!(action)
      plan_action(action, acme_org)
      assert_difference 'Audit.count', 1 do
        finalize_action(action)
      end
    end

    describe 'notifications' do
      let(:acme_org) { get_organization(:empty_organization) }

      it 'sends a success notification' do
        stub_action_locking!(action)
        plan_action(action, acme_org)

        except_notification(action, :success) do |_task|
          ::Katello::UINotifications::Subscriptions::ManifestDeleteSuccess.expects(:deliver!).with(acme_org)
        end
      end

      it 'sends a failure notification when the task ends with warning' do
        stub_action_locking!(action)
        plan_action(action, acme_org)

        except_notification(action, :warning) do |task|
          ::Katello::UINotifications::Subscriptions::ManifestDeleteError.expects(:deliver!).with(
            :subject => acme_org,
            :task => task
          )
        end
      end

      it 'sends a failure notification when the task was cancelled' do
        stub_action_locking!(action)
        plan_action(action, acme_org)

        except_notification(action, :cancelled) do |task|
          ::Katello::UINotifications::Subscriptions::ManifestDeleteError.expects(:deliver!).with(
            :subject => acme_org,
            :task => task
          )
        end
      end

      it 'sends a failure notification when the task ends with error' do
        stub_action_locking!(action)
        plan_action(action, acme_org)

        except_notification(action, :error) do |task|
          ::Katello::UINotifications::Subscriptions::ManifestDeleteError.expects(:deliver!).with(
            :subject => acme_org,
            :task => task
          )
        end
      end
    end
  end
end
