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

    let(:cdn_resource) do
      ::Katello::Resources::CDN::CdnResource.new("http://foo.com").tap do |cdn_resource|
        cdn_resource.stubs('get')
        cdn_resource.stubs('valid_path?': true)
      end
    end

    let(:import_metadata) do
      prod = katello_products(:redhat)

      {
        products: {
          prod.label => prod.slice(:name, :label).merge(redhat: prod.redhat?),
        },
        gpg_keys: {},
        repositories: {
          "misc-24037" => { label: prod.repositories.first.label,
                            product: prod.slice(:label),
                            redhat: prod.redhat?,
          },
        },
        content_view_version: {
          major: '1',
          minor: '0',
        },
        content_view: {
          name: "Export-Repository",
          label: 'Export-Repository',
          description: 'great',
          generated_for: :repository_export,
        },
        destination_server: "wow",
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
      SmartProxy.any_instance.stubs(:ping_pulp).returns({})
      SmartProxy.any_instance.stubs(:ping_pulp3).returns({})
      SmartProxy.any_instance.stubs(:pulp3_configuration).returns(nil)
      ::Katello::Pulp3::Repository.any_instance.stubs(:create_remote).returns(nil)
      ::Katello::Pulp3::Api::ContentGuard.any_instance.stubs(:list).returns(nil)
      ::Katello::Pulp3::Api::ContentGuard.any_instance.stubs(:create).returns(nil)
      ::Katello::Product.any_instance.stubs(cdn_resource: cdn_resource)
      ::Katello::Resources::Candlepin::Content.stubs(:get).returns
    end

    describe 'Import Repository' do
      it 'should plan properly' do
        action_class.any_instance.expects(:action_subject).with(organization)
        plan_action(action, organization, { path: path, metadata: import_metadata })
        assert_action_planned_with(action, ::Actions::Katello::ContentViewVersion::Import) do |options|
          options = options.first if options.is_a? Array
          assert_equal options[:organization], organization
          assert_equal options[:metadata], import_metadata
          assert_equal options[:path], path
        end
      end

      it 'should plan the full tree appropriately' do
        ::Katello::Pulp3::ContentViewVersion::Import.any_instance.expects(:check!).returns
        ::Katello::ContentViewManager.expects(:create_candlepin_environment).returns

        tree = plan_action_tree(action_class, organization, { path: path, metadata: import_metadata })
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
