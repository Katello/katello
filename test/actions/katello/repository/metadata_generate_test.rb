require 'katello_test_helper'

module Actions
  describe Katello::Repository::MetadataGenerate do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::MetadataGenerate }
    let(:pulp_metadata_generate_class) { ::Actions::Pulp3::Orchestration::Repository::GenerateMetadata }
    let(:yum_repo) { katello_repositories(:fedora_17_x86_64) }
    let(:yum_repo2) { katello_repositories(:fedora_17_x86_64_dev) }
    let(:action_options) do
      {
        :source_repository => nil,
        :matching_content => false,
        :force_publication => false
      }
    end

    it 'plans a yum metadata generate' do
      action = create_action(action_class)
      plan_action(action, yum_repo)

      assert_action_planned_with(action, pulp_metadata_generate_class, yum_repo, SmartProxy.pulp_primary,
            **action_options)
    end

    it 'plans a yum refresh in other location' do
      old_location = Location.current
      Location.current = taxonomies(:location1)

      action = create_action(action_class)
      plan_action(action, yum_repo)

      assert_action_planned_with(action, pulp_metadata_generate_class, yum_repo, SmartProxy.pulp_primary,
                                **action_options)
    ensure
      Location.current = old_location
    end

    it 'plans a yum refresh with source repo' do
      action = create_action(action_class)
      plan_action(action, yum_repo, :source_repository => yum_repo2)

      yum_action_options = action_options.clone
      yum_action_options[:source_repository] = yum_repo2

      assert_action_planned_with(action, pulp_metadata_generate_class, yum_repo, SmartProxy.pulp_primary,
            **yum_action_options)
    end

    it 'plans a yum refresh with matching content true' do
      action = create_action(action_class)
      plan_action(action, yum_repo, :matching_content => true)

      yum_action_options = action_options.clone
      yum_action_options[:matching_content] = true
      assert_action_planned_with(action, pulp_metadata_generate_class, yum_repo, SmartProxy.pulp_primary,
                                **yum_action_options)
    end

    it 'plans a yum refresh with matching content set to some deferred object' do
      action = create_action(action_class)
      not_falsey = Object.new
      plan_action(action, yum_repo, :matching_content => not_falsey)

      yum_action_options = action_options.clone
      yum_action_options[:matching_content] = not_falsey
      assert_action_planned_with(action, pulp_metadata_generate_class, yum_repo, SmartProxy.pulp_primary,
                                **yum_action_options)
    end
  end
end
