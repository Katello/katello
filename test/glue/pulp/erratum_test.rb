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
  class GlueErratumTestBase < ActiveSupport::TestCase
    include RepositorySupport

    @@package_id = nil

    def self.before_suite
      super
      services  = ['Candlepin', 'ElasticSearch', 'Foreman']
      models    = ['Repository']
      disable_glue_layers(services, models)
      configure_runcible

      VCR.insert_cassette('pulp/content/erratum')

      RepositorySupport.create_and_sync_repo(@loaded_fixtures['katello_repositories']['fedora_17_x86_64']['id'])

      @@full_errata_id = 'RHSA-2010:0858'
    end

    def self.after_suite
      RepositorySupport.destroy_repo
      VCR.eject_cassette
    end
  end

  class GlueErratumTest < GlueErratumTestBase
    def test_backend_data
      RepositorySupport.repo.index_db_errata
      assert @@full_errata_id, Erratum.find_by_errata_id(@@full_errata_id).backend_data['id']
    end

    def test_pulp_data
      RepositorySupport.repo.index_db_errata
      assert @@full_errata_id, Erratum.pulp_data(Erratum.find_by_errata_id(@@full_errata_id).uuid)['id']
    end

    def test_update_from_json
      uuid = RepositorySupport.repo.errata_json.detect { |e| e['id'] == @@full_errata_id }['_id']
      errata_data =  Erratum.pulp_data(uuid)
      erratum = Erratum.create!(:uuid => errata_data['_id'])
      erratum.update_from_json(errata_data)
      %w(title severity issued description solution updated summary).each do |attr|
        assert erratum.send(attr)
      end
      assert_equal Erratum::SECURITY, erratum.errata_type

      erratum.reload
      refute_empty erratum.packages
      refute erratum.packages.first.filename.blank?
      refute erratum.packages.first.nvrea.blank?
      refute erratum.packages.first.name.blank?

      refute_empty erratum.bugzillas
      refute_empty erratum.bugzillas.first.bug_id
      refute_empty erratum.bugzillas.first.href

      refute_empty erratum.cves
      refute_empty erratum.cves.first.cve_id
      refute_empty erratum.cves.first.href
    end
  end
end
