require 'katello_test_helper'

module Actions
  describe Katello::Repository::UpdateRedhatRepository do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::UpdateRedhatRepository }
    let(:refresh_class) { ::Actions::Katello::Repository::RefreshRepository }
    let(:acs_remote_refresh_class) { ::Actions::Pulp3::Orchestration::AlternateContentSource::RefreshRemote }
    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:simplified_acs) { katello_alternate_content_sources(:yum_simplified_alternate_content_source) }
    let(:proxy) { SmartProxy.pulp_primary }

    it 'plans' do
      action = create_action(action_class)

      repo.content.update!(content_url: "/foo/bar")

      expected_relative_path = repo.generate_repo_path(repo.generate_content_path)
      expected_upstream_url = repo.product.repo_url(repo.generate_content_path)

      action.expects(:action_subject).with(repo)
      # now change the actual values
      repo.root.update!(:url => "http://foo")
      repo.update!(relative_path: "1/#{repo.relative_path}")
      plan_action(action, repo)

      assert_equal expected_upstream_url, repo.root.url
      assert_equal expected_relative_path, repo.relative_path

      assert_action_planned_with(action, refresh_class, repo)
    end

    it 'plans to refresh ACS remote' do
      ::Katello::SmartProxyAlternateContentSource.create(repository_id: repo.id,
        alternate_content_source_id: simplified_acs.id, smart_proxy_id: proxy.id)

      tree = plan_action_tree(action_class, repo)
      assert_tree_planned_with(tree, acs_remote_refresh_class)
    end
  end
end
