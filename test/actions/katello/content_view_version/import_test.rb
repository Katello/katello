require 'katello_test_helper'

module ::Actions::Katello::ContentViewVersion
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include Support::Actions::RemoteAction
    include Support::ExportSupport
    let(:action_class) do
      ::Actions::Katello::ContentViewVersion::Import
    end

    let(:action) do
      create_action action_class
    end

    let(:organization) do
      content_view.organization
    end

    let(:content_view) do
      content_view_version.content_view
    end

    let(:content_view_version) do
      katello_content_view_versions(:library_no_filter_view_version_1)
    end

    let(:cdn_resource) do
      ::Katello::Resources::CDN::CdnResource.new("http://foo.com").tap do |cdn_resource|
        cdn_resource.stubs('get')
        cdn_resource.stubs('valid_path?': true)
      end
    end

    let(:prod) do
      katello_products(:redhat)
    end

    let(:import_metadata) do
      {
        products: {
          prod.label => prod.slice(:label, :name).merge(redhat: prod.redhat?)
        },
        repositories: {
          "misc-24037" => { label: prod.repositories.first.label,
                            product: prod.slice(:label),
                            redhat: prod.redhat?
          }
        },
        gpg_keys: {},
        content_view_version: {
          major: content_view_version.major,
          minor: content_view_version.minor,
          description: description
        },
        content_view: content_view.slice(:label, :name, :description, :generated_for)
      }.with_indifferent_access
    end

    let(:description) do
      "cool cvv"
    end

    let(:path) do
      "/tmp/foo"
    end

    def setup_proxy
      proxy = SmartProxy.pulp_primary
      SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)
      proxy.smart_proxy_features.where(:feature_id => Feature.find_by(:name => SmartProxy::PULP_FEATURE)).delete_all
    end

    before do
      set_user
      Katello::Product.any_instance.stubs(cdn_resource: cdn_resource)
      ::Katello::Resources::Candlepin::Content.stubs(:get).returns
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
      SmartProxy.any_instance.stubs(:pulp3_configuration).returns(nil)
      ::Katello::Pulp3::Repository.any_instance.stubs(:create_remote).returns(nil)
      ::Katello::Pulp3::Api::ContentGuard.any_instance.stubs(:list).returns(nil)
      ::Katello::Pulp3::Api::ContentGuard.any_instance.stubs(:create).returns(nil)
    end
  end

  class ImportTest < TestBase
    before do
      setup_proxy
      content_view.import_only = true
      ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.stubs(:ensure_pulp_importable!).returns
    end

    describe 'Import' do
      it 'should fail on importing content for an existing versions' do
        exception = assert_raises(RuntimeError) do
          plan_action(action, organization: organization, path: path, metadata: import_metadata)
        end
        assert_match(/'#{content_view_version.name}' already exists/, exception.message)
      end

      it 'should plan properly' do
        import_metadata[:content_view_version][:major] += 10

        ::Katello::Pulp3::ContentViewVersion::Import.any_instance.expects(:check!).returns

        plan_action(action, organization: organization, path: path, metadata: import_metadata)
        assert_action_planned_with(action,
                                    ::Actions::Katello::ContentView::Publish,
                                    content_view, description,
                                    path: path,
                                    metadata: import_metadata,
                                    importing: true,
                                    syncable: false,
                                    major: import_metadata[:content_view_version][:major],
                                    minor: import_metadata[:content_view_version][:minor])
      end

      it 'should create a non existent cv and plan properly' do
        import_metadata[:content_view] = { name: "non_existent_view", label: "nope", generated_for: :none }
        ::Katello::Pulp3::ContentViewVersion::Import.any_instance.expects(:check!).returns

        plan_action(action, organization: organization, path: path, metadata: import_metadata)
        content_view = ::Katello::ContentView.find_by(label: import_metadata[:content_view][:label],
                                                      organization: organization)
        refute_nil content_view
        assert content_view.import_only?
        assert_action_planned_with(action,
                                    ::Actions::Katello::ContentView::Publish,
                                    content_view, description,
                                    path: path,
                                    metadata: import_metadata,
                                    importing: true,
                                    syncable: false,
                                    major: import_metadata[:content_view_version][:major],
                                    minor: import_metadata[:content_view_version][:minor])
      end

      it 'should create the library cv and plan properly' do
        import_metadata[:content_view] = { name: ::Katello::ContentView::EXPORT_LIBRARY,
                                           label: ::Katello::ContentView::EXPORT_LIBRARY,
                                           generated_for: :library_export
                                         }
        ::Katello::Pulp3::ContentViewVersion::Import.any_instance.expects(:check!).returns

        plan_action(action, organization: organization, path: path, metadata: import_metadata)
        content_view = ::Katello::ContentView.find_by(label: ::Katello::ContentView::IMPORT_LIBRARY,
                                                      organization: organization)
        refute_nil content_view
        assert content_view.import_only?
        assert_action_planned_with(action,
                                    ::Actions::Katello::ContentView::Publish,
                                    content_view, description,
                                    path: path,
                                    metadata: import_metadata,
                                    importing: true,
                                    syncable: false,
                                    major: import_metadata[:content_view_version][:major],
                                    minor: import_metadata[:content_view_version][:minor])
      end

      it 'should plan the full tree appropriately' do
        ::Katello::Pulp3::ContentViewVersion::Import.any_instance.expects(:check!).returns

        ::Katello::ContentViewManager.expects(:create_candlepin_environment).returns
        import_metadata[:content_view_version][:major] += 10
        generated_cvv = nil
        tree = plan_action_tree(action_class, organization: organization, path: path, metadata: import_metadata)

        assert_empty tree.errors
        assert_tree_planned_steps(tree, Actions::Katello::ContentView::AddToEnvironment)
        assert_tree_planned_steps(tree, Actions::Katello::ContentViewVersion::CreateRepos)
        assert_tree_planned_steps(tree, Actions::Pulp3::Orchestration::ContentViewVersion::Import)
        assert_tree_planned_steps(tree, Actions::Pulp3::Orchestration::ContentViewVersion::CopyVersionUnitsToLibrary)

        assert_tree_planned_with(tree, Actions::Pulp3::ContentViewVersion::CreateImporter) do |input|
          assert_equal SmartProxy.pulp_primary.id, input[:smart_proxy_id]
          assert_equal path, input[:path]
          generated_cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          assert_equal content_view_version.content_view.id, generated_cvv.content_view.id
          assert_equal import_metadata[:content_view_version][:major], generated_cvv.major
          assert_equal import_metadata[:content_view_version][:minor], generated_cvv.minor
        end

        assert_tree_planned_with(tree, Actions::Pulp3::ContentViewVersion::CreateImport) do |input|
          assert_equal SmartProxy.pulp_primary.id, input[:smart_proxy_id]
          assert_equal path, input[:path]
          assert_equal content_view_version.content_view.organization_id, input[:organization_id]
          refute_nil input[:importer_data]
        end

        assert_tree_planned_with(tree, ::Actions::Pulp3::ContentViewVersion::CreateImportHistory) do |input|
          assert_equal path, input[:path]
          assert_equal generated_cvv.id, input[:content_view_version_id]
          assert_equal generated_cvv.name, input[:content_view_name]
          refute_nil input[:metadata]
        end
        assert_tree_planned_with(tree, Actions::Pulp3::ContentViewVersion::DestroyImporter)

        assert_tree_planned_with(tree, Actions::Pulp3::Repository::CopyContent) do |input|
          assert input[:copy_all]
          refute input[:mirror]
          refute_nil input[:source_repository_id]
          refute_nil input[:target_repository_id]
          refute_nil input[:smart_proxy_id]
        end
      end
    end
  end
end
