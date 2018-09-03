require 'katello_test_helper'

module Katello
  module Service
    class ManagedContentMediumProviderTestBase < ActiveSupport::TestCase
    end

    class ManagedContentMediumProvider < ManagedContentMediumProviderTestBase
      setup do
        @org = FactoryBot.create(:katello_organization)
        @distro = FactoryBot.create(:katello_repository)
      end

      def test_unique_id
        host = ::Host::Managed.new(:name => 'foobar', :managed => false, :organization => @org)
        host.content_facet.kickstart_repository = @distro
        host_group = ::Hostgroup.new(:name => 'bar')
        host_group.kickstart_repository = @distro
        assert_not_nil ::Katello::ManagedContentMediumProvider.new(host).unique_id
        assert_not_nil ::Katello::ManagedContentMediumProvider.new(host.content_facet).unique_id
        assert_not_nil ::Katello::ManagedContentMediumProvider.new(host_group).unique_id
      end
    end
  end
end
