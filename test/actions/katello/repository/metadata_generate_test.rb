require 'katello_test_helper'

module Actions
  describe Katello::Repository::MetadataGenerate do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::MetadataGenerate }
    let(:pulp_publish_class) { ::Actions::Pulp::Repository::DistributorPublish }
    let(:yum_repo) { katello_repositories(:fedora_17_x86_64) }
    let(:yum_repo2) { katello_repositories(:fedora_17_x86_64_dev) }
    let(:puppet_repo) { katello_repositories(:p_forge) }

    it 'plans a yum refresh' do
      action = create_action(action_class)
      plan_action(action, yum_repo)

      assert_action_planed_with(action, pulp_publish_class, :pulp_id => yum_repo.pulp_id,
          :distributor_type_id => Runcible::Models::YumDistributor.type_id,
          :source_pulp_id => nil,
          :override_config => {:force_full => false},
          :dependency => nil,
          :matching_content => nil)
    end

    it 'plans a yum refresh with force true' do
      action = create_action(action_class)
      plan_action(action, yum_repo, :force => true)

      assert_action_planed_with(action, pulp_publish_class, :pulp_id => yum_repo.pulp_id,
          :distributor_type_id => Runcible::Models::YumDistributor.type_id,
          :source_pulp_id => nil,
          :override_config => {:force_full => true},
          :dependency => nil,
          :matching_content => nil)
    end

    it 'plans a yum refresh with source repo' do
      action = create_action(action_class)
      plan_action(action, yum_repo, :source_repository => yum_repo2)

      assert_action_planed_with(action, pulp_publish_class, :pulp_id => yum_repo.pulp_id,
          :distributor_type_id => Runcible::Models::YumCloneDistributor.type_id,
          :source_pulp_id => yum_repo2.pulp_id,
          :override_config => {},
          :dependency => nil,
          :matching_content => nil)
    end

    it 'plans a puppet refresh' do
      action = create_action(action_class)
      plan_action(action, puppet_repo)

      assert_action_planed_with(action, pulp_publish_class, :pulp_id => puppet_repo.pulp_id,
          :distributor_type_id => Runcible::Models::PuppetDistributor.type_id,
          :source_pulp_id => nil,
          :override_config => {},
          :dependency => nil,
          :matching_content => nil)
    end
  end
end
