require 'katello_test_helper'

module ::Actions::Katello::Organization
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }

    let(:organization) do
      build(:katello_organization, :acme_corporation, :with_library)
    end

    before do
      set_user
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
      organization.expects(:products).twice.returns([])
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
      upstream = {}
      rhel7 = katello_repositories(:rhel_7_x86_64)
      organization.stubs(:owner_details).returns({})
      organization.products.stubs(:redhat).returns([rhel7.product])
      action.stubs(:action_subject).with(organization)
      action.stubs(:rand).returns('1234')
      plan_action(action, organization)

      assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::UpstreamUpdate,
                                 organization_id: organization.id,
                                 upstream: upstream
                                )
      assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::UpstreamExport,
                                 organization_id: organization.id,
                                 upstream: upstream,
                                 path: "/tmp/1234.zip"
                                )
      assert_action_planned_with(action,
                                 ::Actions::Candlepin::Owner::Import,
                                 label: organization.label,
                                 path: "/tmp/1234.zip"
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
  end
end
