#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  class GluePulpDistributionTestBase < ActiveSupport::TestCase
    include RepositorySupport

    def self.before_suite
      super
      services  = ['Candlepin', 'ElasticSearch', 'Foreman']
      models    = ['Repository', 'Distribution']
      disable_glue_layers(services, models)
      configure_runcible

      VCR.insert_cassette('pulp/content/distribution')

      RepositorySupport.create_and_sync_repo(@loaded_fixtures['katello_repositories']['fedora_17_x86_64']['id'])
    end

    def self.after_suite
      RepositorySupport.destroy_repo
      VCR.eject_cassette
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
