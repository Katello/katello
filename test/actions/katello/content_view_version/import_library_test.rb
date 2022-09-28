require 'katello_test_helper'

module ::Actions::Katello::ContentViewVersion
  class ImportLibraryTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include Support::Actions::RemoteAction
    let(:action_class) do
      ::Actions::Katello::ContentViewVersion::ImportLibrary
    end

    let(:action) do
      create_action action_class
    end

    let(:organization) do
      get_organization
    end

    let(:content_view_version) do
      organization.default_content_view_version
    end

    let(:repo) do
      organization.repositories.redhat.first
    end

    let(:prod) do
      repo.product
    end

    let(:cdn_resource) do
      ::Katello::Resources::CDN::CdnResource.new("http://foo.com").tap do |cdn_resource|
        cdn_resource.stubs('get')
        cdn_resource.stubs('valid_path?': true)
      end
    end

    let(:metadata) do
      {
        products: {
          prod.label => prod.slice(:name, :label).merge(redhat: prod.redhat?)
        },
        gpg_keys: {},
        repositories: {
          "misc-24037" => { label: repo.label,
                            name: repo.name,
                            mirroring_policy: repo.mirroring_policy,
                            product: prod.slice(:label),
                            redhat: prod.redhat?,
                            arch: 'noarch',
                            minor: repo.minor,
                            unprotected: false,
                            content_type: 'yum',
                            download_policy: 'immediate',
                            content: { id: repo.content_id, label: 'misc-24037', url: "/org/cv/dump" }
          }
        },
        content_view_version: {
          major: '1',
          minor: '0'
        },
        content_view: {
          name: ::Katello::ContentView::EXPORT_LIBRARY,
          label: ::Katello::ContentView::EXPORT_LIBRARY,
          description: 'great',
          generated_for: :library_export
        }
      }.with_indifferent_access
    end

    let(:path) do
      "/tmp/foo"
    end

    def setup_proxy
      proxy = SmartProxy.pulp_primary
      SmartProxy.any_instance.stubs(:pulp_primary).returns(proxy)
      SmartProxy.any_instance.stubs(:pulp_primary!).returns(proxy)
      proxy.smart_proxy_features.where(:feature_id => Feature.find_by(:name => SmartProxy::PULP_FEATURE)).delete_all
    end

    before do
      setup_proxy
      Katello::Product.any_instance.stubs(cdn_resource: cdn_resource)
      SmartProxy.any_instance.stubs(:ping_pulp).returns({})
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
      SmartProxy.any_instance.stubs(:pulp3_configuration).returns(nil)
      ::Katello::Pulp3::Repository.any_instance.stubs(:create_remote).returns(nil)
      ::Katello::Pulp3::Api::ContentGuard.any_instance.stubs(:list).returns(nil)
      ::Katello::Pulp3::Api::ContentGuard.any_instance.stubs(:create).returns(nil)
      ::Katello::Repository.any_instance.stubs(:pulp_scratchpad_checksum_type).returns(nil)
      ::Katello::Resources::Candlepin::Content.stubs(:get).returns
    end

    describe 'Import Default' do
      it 'should plan properly' do
        assert_nil ::Katello::ContentView.where(organization: organization,
                                                name: ::Katello::ContentView::IMPORT_LIBRARY).first
        action_class.any_instance.expects(:action_subject).with(organization)
        plan_action(action, organization, path: path, metadata: metadata)
        assert_action_planned_with(action, ::Actions::Katello::ContentViewVersion::Import) do |options|
          options = options.first if options.is_a? Array
          assert_equal options[:organization], organization
          assert_equal options[:metadata], metadata
          assert_equal options[:path], path
        end
      end

      it 'should plan the full tree appropriately' do
        ::Katello::ContentViewManager.expects(:create_candlepin_environment).returns
        ::Katello::Pulp3::ContentViewVersion::Import.any_instance.expects(:check!).returns

        tree = plan_action_tree(action_class, organization, path: path, metadata: metadata)

        assert_empty tree.errors
        assert_tree_planned_with(tree, Actions::Pulp3::Repository::CopyContent) do |input|
          assert input[:copy_all]
          assert input[:mirror]
          refute_nil input[:source_repository_id]
          refute_nil input[:target_repository_id]
          refute_nil input[:smart_proxy_id]
        end
      end
    end
  end
end
