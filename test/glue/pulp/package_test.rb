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

require 'test_helper'
require './test/support/repository_support'


class GluePulpPackageTestBase < ActiveSupport::TestCase
  extend  ActiveRecord::TestFixtures
  include RepositorySupport

  fixtures :all

  @@package_id = nil

  def self.before_suite
    @loaded_fixtures = load_fixtures
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['Repository', 'Package']
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
    RepositorySupport.create_and_sync_repo(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])

    VCR.insert_cassette('glue_pulp_package', :match_requests_on => [:path, :params, :method, :body_json])
    @@package_id = RepositorySupport.repo.packages.first.id
  end

  def self.after_suite
    RepositorySupport.destroy_repo
    VCR.eject_cassette
  end

end


class GluePulpPackageTest < GluePulpPackageTestBase

  def test_find
    package = Package.find(@@package_id)

    refute_nil      package
    assert_kind_of  Package, package
  end

  def test_nvrea
    package = Package.find(@@package_id)

    refute_nil package.nvrea
  end

  def test_ignored_fields
    refute_includes Package::PULP_SELECT_FIELDS, 'changelog'
    refute_includes Package::PULP_SELECT_FIELDS, 'repodata'
    refute_includes Package::PULP_SELECT_FIELDS, 'filelist'
  end

end
