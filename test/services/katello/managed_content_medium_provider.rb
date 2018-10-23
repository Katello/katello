require 'katello_test_helper'

module Katello
  module Service
    class ManagedContentMediumProviderTestBase < ActiveSupport::TestCase
    end

    class ManagedContentMediumProvider < ManagedContentMediumProviderTestBase
      setup do
        @org = FactoryBot.create(:katello_organization)
        @distro = FactoryBot.create(:katello_repository,  :with_product)
        @variant = FactoryBot.create(:katello_repository, :with_product)
      end

      def test_unique_id
        host = FactoryBot.build(:host, :managed, :redhat, :with_content, organization: @org)
        host.content_facet.kickstart_repository = @distro
        host_group = ::Hostgroup.new(:name => 'bar')
        host_group.kickstart_repository = @distro
        assert_not_nil ::Katello::ManagedContentMediumProvider.new(host).unique_id
        assert_not_nil ::Katello::ManagedContentMediumProvider.new(host.content_facet).unique_id
        assert_not_nil ::Katello::ManagedContentMediumProvider.new(host_group).unique_id
      end

      def test_kickstart_repo
        host = FactoryBot.build(:host, :managed, :redhat, :with_content, organization: @org)
        host.content_facet.kickstart_repository = @distro
        provider = ::Katello::ManagedContentMediumProvider.new(host)
        assert_equal provider.kickstart_repo, @distro
      end

      def test_additional_media
        host = FactoryBot.build(:host, :managed, :redhat, organization: @org)
        Redhat.any_instance.expects(:variant_repo).with(host, 'AppStream').returns(@variant.to_hash)
        provider = ::Katello::ManagedContentMediumProvider.new(host)
        assert_includes provider.additional_media, @variant.to_hash
      end
    end
  end
end
