#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'
require './test/support/repository_support'

class GluePulpErrataTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend  ActiveRecord::TestFixtures
  include RepositorySupport

  fixtures :all

  def self.before_suite
    @loaded_fixtures = load_fixtures
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['Repository', 'Errata', 'Package']
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
    RepositorySupport.create_and_sync_repo(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])

    VCR.insert_cassette('glue_pulp_errata', :match_requests_on => [:path, :params, :method, :body_json])
    @@erratum_id = RepositorySupport.repo.errata.select{ |errata| errata.errata_id == 'RHEA-2010:0002' }.first.id
  end

  def self.after_suite
    RepositorySupport.destroy_repo
    VCR.eject_cassette
  end

end


class GluePulpErrataTest < GluePulpErrataTestBase

  def test_find
    erratum = Errata.find(@@erratum_id)

    refute_nil      erratum
    assert_kind_of  Errata, erratum
  end

  def test_errata_by_consumer
    Runcible::Extensions::Consumer.expects(:applicable_errata).
        with([], [RepositorySupport.repo.pulp_id], false).returns({})

    Errata.errata_by_consumer([RepositorySupport.repo])
  end

  def test_included_packages
    erratum   = Errata.find(@@erratum_id)
    packages  = erratum.included_packages

    refute_empty packages
    refute_empty packages.select { |package| package.name == "elephant" }
  end

  def test_product_ids
    erratum     = Errata.find(@@erratum_id)
    product_ids = erratum.included_packages

    refute_empty product_ids
  end

end
