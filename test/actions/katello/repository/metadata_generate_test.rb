require 'katello_test_helper'

module Actions
  describe Katello::Repository::MetadataGenerate do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::MetadataGenerate }
    let(:select_class) { ::Actions::Katello::PulpSelector }
    let(:pulp_publish_classes) { [::Actions::Pulp::Repository::DistributorPublish, Pulp3::Orchestration::Repository::GenerateMetadata] }
    let(:yum_repo) { katello_repositories(:fedora_17_x86_64) }
    let(:yum_repo2) { katello_repositories(:fedora_17_x86_64_dev) }
    let(:puppet_repo) { katello_repositories(:p_forge) }
    let(:content_view_puppet_env) { katello_content_view_puppet_environments(:library_view_puppet_environment) }

    before do
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
    end

    it 'plans a yum refresh' do
      action = create_action(action_class)
      plan_action(action, yum_repo)

      assert_action_planed_with(action, select_class, pulp_publish_classes, yum_repo, SmartProxy.pulp_master,
            :force => false, :matching_content => nil, :source_repository => nil, :dependency => nil, :repository_creation => false)
    end

    it 'plans with a content view puppet env' do
      action = create_action(action_class)
      content_view_puppet_env.puppet_environment = ::Environment.create(:name => 'foobar')

      plan_action(action, content_view_puppet_env)

      assert_action_planed_with(action, select_class, pulp_publish_classes, content_view_puppet_env, SmartProxy.pulp_master,
              :force => false, :matching_content => nil, :source_repository => nil, :dependency => nil, :repository_creation => false)
    end

    it 'plans a yum refresh with force true' do
      action = create_action(action_class)
      plan_action(action, yum_repo, :force => true)

      assert_action_planed_with(action, select_class, pulp_publish_classes, yum_repo, SmartProxy.pulp_master,
            :force => true, :matching_content => nil, :source_repository => nil, :dependency => nil, :repository_creation => false)
    end

    it 'plans a yum refresh with source repo' do
      action = create_action(action_class)
      plan_action(action, yum_repo, :source_repository => yum_repo2)

      assert_action_planed_with(action, select_class, pulp_publish_classes, yum_repo, SmartProxy.pulp_master,
            :force => false, :matching_content => nil, :source_repository => yum_repo2, :dependency => nil, :repository_creation => false)
    end
  end
end
