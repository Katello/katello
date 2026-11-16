require 'katello_test_helper'

module ::Actions::Pulp3::Orchestration::Repository
  class GenerateMetadataTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:action_class) { ::Actions::Pulp3::Orchestration::Repository::GenerateMetadata }
    let(:action) { create_action action_class }
    let(:source) { katello_repositories(:fedora_17_x86_64) }
    let(:target) { katello_repositories(:fedora_17_x86_64_dev) }

    before do
      target.update_columns(:publication_href => '/pulp/api/v3/publications/rpm/rpm/1/')
    end

    it 'does not refresh a repository that is not distributed' do
      refute Setting[:distribute_archived_cvv]
      archive = katello_repositories(:fedora_17_x86_64_dev_archive)

      plan_action(action, archive, SmartProxy.pulp_primary, :source_repository => source, :contents_changed => true)

      refute_action_planned(action, ::Actions::Pulp3::Repository::RefreshDistribution)
    end

    it 'refreshes the distribution when the content changed' do
      plan_action(action, target, SmartProxy.pulp_primary, :source_repository => source, :contents_changed => true)

      assert_action_planned(action, ::Actions::Pulp3::Repository::RefreshDistribution)
    end

    it 'refreshes a distribution the clone has never had' do
      plan_action(action, target, SmartProxy.pulp_primary, :source_repository => source, :contents_changed => false)

      assert_action_planned(action, ::Actions::Pulp3::Repository::RefreshDistribution)
    end

    it 'refreshes when no source proves the publication was reused' do
      target.distribution_references.create!(:path => '/acme/dev/fedora_17', :href => '/pulp/api/v3/distributions/rpm/rpm/1/')

      plan_action(action, target, SmartProxy.pulp_primary, :contents_changed => false)

      assert_action_planned(action, ::Actions::Pulp3::Repository::RefreshDistribution)
    end

    it 'skips the refresh when the clone already serves the publication' do
      target.distribution_references.create!(:path => '/acme/dev/fedora_17', :href => '/pulp/api/v3/distributions/rpm/rpm/1/')
      source.update_columns(:publication_href => target.publication_href)

      plan_action(action, target, SmartProxy.pulp_primary, :source_repository => source, :contents_changed => false)

      refute_action_planned(action, ::Actions::Pulp3::Repository::RefreshDistribution)
    end

    it 'skips when the source publication is not materialised yet' do
      target.distribution_references.create!(:path => '/acme/dev/fedora_17', :href => '/pulp/api/v3/distributions/rpm/rpm/1/')
      source.update_columns(:publication_href => nil)

      plan_action(action, target, SmartProxy.pulp_primary, :source_repository => source, :contents_changed => false)

      refute_action_planned(action, ::Actions::Pulp3::Repository::RefreshDistribution)
    end

    it 'refreshes when the source publication differs from the clone publication' do
      target.distribution_references.create!(:path => '/acme/dev/fedora_17', :href => '/pulp/api/v3/distributions/rpm/rpm/1/')
      source.update_columns(:publication_href => '/pulp/api/v3/publications/rpm/rpm/2/')

      plan_action(action, target, SmartProxy.pulp_primary, :source_repository => source, :contents_changed => false)

      assert_action_planned(action, ::Actions::Pulp3::Repository::RefreshDistribution)
    end
  end
end
