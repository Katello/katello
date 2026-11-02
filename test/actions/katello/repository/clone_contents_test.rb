require 'katello_test_helper'

module ::Actions::Katello::Repository
  class CloneContentsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:action_class) { ::Actions::Katello::Repository::CloneContents }
    let(:action) { create_action action_class }
    let(:source) { katello_repositories(:fedora_17_x86_64) }
    let(:target) { katello_repositories(:fedora_17_x86_64_dev) }

    before do
      User.current = users(:admin)
    end

    it 'generates metadata by default' do
      plan_action(action, [source], target, :copy_contents => false, :filters => [], :rpm_filenames => [])

      assert_action_planned(action, ::Actions::Katello::Repository::MetadataGenerate)
    end

    it 'defers metadata and the check that only feeds it' do
      plan_action(action, [source], target, :copy_contents => false, :generate_metadata => false, :filters => [])

      refute_action_planned(action, ::Actions::Katello::Repository::MetadataGenerate)
      refute_action_planned(action, ::Actions::Katello::Repository::CheckMatchingContent)
    end

    it 'keeps the checksum type when metadata is deferred' do
      source.update_columns(:saved_checksum_type => 'sha256')
      target.update_columns(:saved_checksum_type => 'sha1')

      plan_action(action, [source], target, :copy_contents => false, :generate_metadata => false, :filters => [])

      assert_equal 'sha256', action.input[:source_checksum_type]
    end
  end
end
