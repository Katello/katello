require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  class GluePulpDistributionTestBase < ActiveSupport::TestCase
    include RepositorySupport

    def self.before_suite
      super
      configure_runcible

      VCR.insert_cassette('pulp/content/distribution')

      RepositorySupport.create_and_sync_repo(@loaded_fixtures['katello_repositories']['fedora_17_x86_64']['id'])
    end

    def self.after_suite
      run_as_admin do
        RepositorySupport.destroy_repo
        VCR.eject_cassette
      end
    end
  end

  class GluePulpDistributionTest < GluePulpDistributionTestBase
    def test_find
      distribution = Distribution.find("ks-Test Family-TestVariant-16-x86_64")

      refute_nil distribution
      assert_kind_of Distribution, distribution
    end
  end
end
