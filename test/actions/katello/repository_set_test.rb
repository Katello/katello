require 'katello_test_helper'

module ::Actions::Katello::RepositorySet
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before do
      disable_lazy_accessors
      get_organization(:empty_organization)
      product.stubs(cdn_resource: cdn_resource)
    end

    let(:cdn_resource) do
      ::Katello::Resources::CDN::CdnResource.new(content_url).tap do |cdn_resource|
        cdn_resource.stubs(:get).returns('x86_64', '6Server')
      end
    end

    let(:content_url) { '/product/$basearch/$releasever' }
    let(:action) { create_action action_class }
    let(:product) { katello_products(:redhat) }
    let(:content) do
      ::Katello::Candlepin::Content.new(id: 'content-123',
                                        name: 'Content 123',
                                        type: 'yum',
                                        label: 'content-123',
                                        contentUrl: content_url)
    end
    let(:substitutions) { { basearch: 'x86_64', releasever: '6Server' } }
    let(:expected_relative_path) { "Empty_Organization/library_label/product/x86_64/6Server" }

    def repository_already_enabled!
      katello_repositories(:rhel_6_x86_64).
          update_attributes!(:relative_path => "#{expected_relative_path}", :content_id => content.id,
                            :arch => 'x86_64', :minor => '6Server')
    end
  end

  class EnableRepositoryTest < TestBase
    let(:action_class) { ::Actions::Katello::RepositorySet::EnableRepository }

    it 'plans' do
      action.expects(:action_subject).with do |repository|
        repository.relative_path.must_equal expected_relative_path
      end
      content.expects(:modifiedProductIds).returns([])
      plan_action action, product, content, substitutions
      assert_action_planed action, ::Actions::Katello::Repository::Create
    end

    it 'fails when repository already enabled' do
      repository_already_enabled!
      failed = lambda do
        plan_action(action, product, content, substitutions)
      end
      failed.must_raise(::Katello::Errors::ConflictException)
    end
  end

  class DisableRepositoryTest < TestBase
    let(:action_class) { ::Actions::Katello::RepositorySet::DisableRepository }

    it 'plans' do
      repository_already_enabled!

      action.expects(:action_subject).with do |repository|
        repository.relative_path.must_equal expected_relative_path
      end
      plan_action action, product, content, substitutions
      assert_action_planed action, ::Actions::Katello::Repository::Destroy
    end

    it 'fails when repository not enabled' do
      failed = lambda do
        plan_action(action, product, content, substitutions)
      end
      failed.must_raise(::Katello::Errors::NotFound)
    end
  end

  class ScanCdnTest < TestBase
    include Support::Actions::RemoteAction

    let(:action_class) { ::Actions::Katello::RepositorySet::ScanCdn }

    before do
      product.stubs(product_content_by_id: stub(content: content))
      stub_remote_user
    end

    it 'plans' do
      plan_action action, product, content.id
      assert_run_phase action do
        action.input[:product_id].must_equal product.id
        action.input[:content_id].must_equal content.id
      end
    end

    it 'runs' do
      SecureRandom.expects(:uuid).returns('foobar')
      action = simulate_run
      action.output.
          must_equal("results" =>
                       [{"substitutions" => {"basearch" => "x86_64", "releasever" => "6Server"},
                         "path" => "/product/x86_64/6Server",
                         "repo_name" => "Content 123 x86_64 6Server",
                         "name" => "Content 123",
                         "pulp_id" => 'foobar',
                         "repository_id" => nil,
                         "enabled" => false,
                         "promoted" => false}])
    end

    it 'considers the repo being enabled when the repository object is present' do
      repository_already_enabled!
      action = simulate_run
      action.output[:results].first[:enabled].must_equal true
    end

    def simulate_run
      planned_action = plan_action action, product, content.id

      run_action planned_action do |run_action|
        substitutor = stub(:cdn_var_substitutor)
        substitutor.stubs(substitute_vars: [Katello::Util::PathWithSubstitutions.new(content_url, substitutions)])
        run_action.stubs(content: content)
        run_action.stubs(cdn_var_substitutor: substitutor)
      end
    end
  end
end
