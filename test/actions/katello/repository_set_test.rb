require 'katello_test_helper'

module ::Actions::Katello::RepositorySet
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

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
      FactoryBot.build(:katello_content,
                       cp_content_id: 'content-123',
                       name: 'Content 123',
                       content_type: 'yum',
                       label: 'content-123',
                       content_url: content_url)
    end
    let(:substitutions) { { basearch: 'x86_64', releasever: '6Server' } }
    let(:expected_relative_path) { "Empty_Organization/library_label/product/x86_64/6Server" }

    def repository_already_enabled!
      as_admin do
        katello_repositories(:rhel_6_x86_64).
            update!(:relative_path => "#{expected_relative_path}")
        katello_repositories(:rhel_6_x86_64).root.
            update(:content_id => content.cp_content_id,
                              :arch => 'x86_64', :minor => '6Server')
      end
    end
  end

  class EnableRepositoryTest < TestBase
    let(:action_class) { ::Actions::Katello::RepositorySet::EnableRepository }

    it 'plans' do
      action.expects(:action_subject).with do |repository|
        assert_equal expected_relative_path, repository.relative_path
      end
      plan_action action, product, content, substitutions
      assert_action_planed action, ::Actions::Katello::Repository::Create
    end

    it 'fails when repository already enabled' do
      repository_already_enabled!
      assert_raises(::Katello::Errors::ConflictException) do
        plan_action(action, product, content, substitutions)
      end
    end
  end

  class DisableRepositoryTest < TestBase
    let(:action_class) { ::Actions::Katello::RepositorySet::DisableRepository }

    it 'plans' do
      repository_already_enabled!

      action.expects(:action_subject).with do |repository|
        assert_equal expected_relative_path, repository.relative_path
      end
      plan_action action, product, content, substitutions
      assert_action_planed action, ::Actions::Katello::Repository::Destroy
    end

    it 'fails when repository not enabled' do
      assert_raises(::Katello::Errors::NotFound) do
        plan_action(action, product, content, substitutions)
      end
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
      plan_action action, product, content.cp_content_id
      assert_run_phase action do
        assert_equal action.input[:product_id], product.id
        assert_equal action.input[:content_id], content.cp_content_id
      end
    end

    it 'runs' do
      SecureRandom.expects(:uuid).returns('foobar')
      action = simulate_run
      expected = {
        "results" => [{
          "substitutions" => {"basearch" => "x86_64", "releasever" => "6Server"},
          "path" => "/product/x86_64/6Server",
          "repo_name" => "Content 123 x86_64 6Server",
          "name" => "Content 123",
          "pulp_id" => 'foobar',
          "repository_id" => nil,
          "enabled" => false,
          "promoted" => false
        }]
      }

      assert_equal expected, action.output
    end

    it 'considers the repo being enabled when the repository object is present' do
      repository_already_enabled!
      action = simulate_run
      assert_equal action.output[:results].first[:enabled], true
    end

    it 'raises CdnSubstitutionError when substitute_vars fails' do
      planned_action = plan_action action, product, content.id

      error_message = "Failed at scanning for repository: Connection refused - connect(2) for \"cdn.redhat.com\" port 443"

      Katello::Util::CdnVarSubstitutor.any_instance.stubs(:substitute_vars).raises(Katello::Errors::CdnSubstitutionError, error_message)

      assert_raises_with_message Katello::Errors::CdnSubstitutionError, error_message do
        run_action planned_action do |run_action|
          substitutor = stub(:cdn_var_substitutor)
          substitutor.stubs(:substitute_vars).raises(Katello::Errors::CdnSubstitutionError, error_message)
          run_action.stubs(content: content)
          run_action.stubs(cdn_var_substitutor: substitutor)
        end
      end
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
