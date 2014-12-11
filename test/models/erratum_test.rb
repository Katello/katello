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

require File.expand_path("repository_base", File.dirname(__FILE__))

module Katello
  class ErratumTestBase < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:rhel_6_x86_64)
      @security = katello_errata(:security)
      @bugfix = katello_errata(:bugfix)
      @enhancement = katello_errata(:enhancement)
      @errata_server = katello_systems(:errata_server)
      @simple_server = katello_systems(:simple_server)
    end
  end

  class ErratumTest < ErratumTestBase
    def test_repositories
      assert_includes @security.repository_ids, @repo.id
    end

    def test_create
      uuid = 'foo'
      assert Erratum.create!(:uuid => uuid)
      assert Erratum.find_by_uuid(uuid)
    end

    def test_of_type
      assert Erratum.of_type(Erratum::SECURITY).include?(@security)
      refute Erratum.of_type(Erratum::SECURITY).include?(@bugfix)
      refute Erratum.of_type(Erratum::SECURITY).include?(@enhancement)
    end

    def test_applicable_to_systems
      errata =  Erratum.applicable_to_systems([@errata_server, @simple_server])
      assert_includes errata, @security
      assert_includes errata, @bugfix
      refute_includes errata, @enhancement
    end

    def test_not_applicable_to_systems
      assert_empty Erratum.applicable_to_systems([@simple_server])
    end

    def test_update_from_json
      errata = katello_errata(:security)
      json = errata.attributes.merge('description' => 'an update', 'updated' => DateTime.now)
      errata.update_from_json(json)
      assert_equal Erratum.find(errata).description, json['description']
    end

    def test_update_from_json_is_idempotent
      errata = katello_errata(:security)
      last_updated = errata.updated_at
      json = errata.attributes
      errata.update_from_json(json)
      assert_equal Erratum.find(errata).updated_at, last_updated
    end
  end

  class ErratumAvailableTest < ErratumTestBase
    def setup
      super
      Katello::System.any_instance.stubs(:save_candlepin_orchestration).returns(:true)
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1))
      @errata_server.bound_repositories = [@view_repo]
      @errata_server.save!
    end

    def test_systems_available
      assert_includes @security.systems_available, @errata_server
      refute_includes @security.systems_available, @simple_server
      refute_includes @bugfix.systems_available, @simple_server
    end

    def test_available_for_systems
      errata = Erratum.available_for_systems([@errata_server, @simple_server])
      assert_includes errata, @security
      refute_includes errata, @bugfix
      refute_includes errata, @enhancement
    end
  end
end
