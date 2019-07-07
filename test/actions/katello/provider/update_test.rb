require 'katello_test_helper'

module Actions
  describe Katello::Provider::Update do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Provider::Update }
    let(:repository_update_class) { ::Actions::Katello::Repository::Update }

    before :all do
      @provider = katello_providers(:redhat)
    end

    it 'plans' do
      action = create_action(action_class)
      action.expects(:action_subject).with(@provider)
      plan_action(action, @provider, :redhat_repository_url => 'http://localhost')
      repositories = @provider.products.enabled.collect { |product| product.repositories }
      repositories.flatten!
      root_repositories = repositories.reject { |r| r.url.blank? }.group_by(&:root).collect do |root, _|
        content_url = root.content.content_url
        assert_not_empty content_url

        path = root.repo_mapper.path
        assert_match(/#{content_url.gsub(/\$[^\/]+/, "[^\/]+")}/, path)

        [root, {:url => "http://localhost" + path}]
      end

      actual_repositories = []
      assert_action_planed_with(action, repository_update_class) do |repository|
        assert_includes root_repositories, repository
        actual_repositories << repository
      end

      # Make sure we don't update the same repo multiple times
      assert_equal root_repositories.uniq.sort, actual_repositories.sort
    end
  end
end
