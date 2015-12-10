require 'katello_test_helper'

module Actions
  describe Katello::Provider::Update do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Provider::Update }
    let(:repository_update_class) { ::Actions::Katello::Repository::Update }

    before :all do
      @provider = katello_providers(:redhat)
    end

    it 'plans' do
      action = create_action(action_class)
      action.expects(:action_subject).with(@provider)
      plan_action(action, @provider, :redhat_repository_url => 'https://localhost')
      repositories = @provider.products.enabled.collect { |product| product.repositories }
      repositories.flatten!
      repositories = repositories.collect do |repository|
        next unless repository.url
        [repository, {:url => "https://localhost#{repository.url.gsub('https://cdn.example.com', '')}"}]
      end

      assert_action_planed_with(action, repository_update_class) do |repository|
        assert_includes repositories, repository
      end
    end
  end
end
