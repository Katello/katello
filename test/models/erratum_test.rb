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

    def test_create_truncates_long_title
      attrs = {:uuid => 'foo', :title => "This life, which had been the tomb of " \
        "his virtue and of his honour is but a walking shadow; a poor player, " \
        "that struts and frets his hour upon the stage, and then is heard no more: " \
        "it is a tale told by an idiot, full of sound and fury, signifying nothing." \
        " - William Shakespeare"}
      assert Erratum.create!(attrs)
      assert_equal Erratum.find_by_uuid(attrs[:uuid]).title.size, 255
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

    def test_update_from_json_truncates_title
      errata = katello_errata(:security)
      title = "There is a tide in the affairs of men, Which taken at the flood, leads on to " \
        "fortune.  Omitted, all the voyage of their life is bound in shallows and in miseries. "\
        "On such a full sea are we now afloat. And we must take the current when it serves, or "\
        "lose our ventures. - William Shakespeare"
      json = errata.attributes.merge('description' => 'an update', 'updated' => DateTime.now, 'title' => title)
      errata.update_from_json(json)
      assert_equal Erratum.find(errata).title.size, 255
    end

    def test_update_from_json_duplicate_packages #Issue 9312
      pkg = {:name => 'foo', :version => 3, :arch => 'x86_64', :epoch => 0, :release => '.el3', :filename => 'blahblah.rpm'}.with_indifferent_access
      pkg_list = [pkg, pkg]
      errata = katello_errata(:security)

      pkg_count = errata.packages.count
      json = errata.attributes.merge('description' => 'an update', 'updated' => DateTime.now, 'pkglist' => [{'packages' => pkg_list}])
      errata.update_from_json(json)

      assert_equal errata.reload.packages.count, pkg_count + 1
    end

    def test_update_from_json_new_packages
      pkg = {:name => 'foo', :version => 3, :arch => 'x86_64', :epoch => 0, :release => '.el3', :filename => 'blahblah.rpm'}.with_indifferent_access
      pkg2 = {:name => 'bar', :version => 3, :arch => 'x86_64', :epoch => 0, :release => '.el3', :filename => 'foo.rpm'}.with_indifferent_access
      errata = katello_errata(:security)
      pkg_count = errata.packages.count

      json = errata.attributes.merge('pkglist' => [{'packages' => [pkg]}])
      errata.update_from_json(json)
      assert_equal errata.reload.packages.count, pkg_count + 1

      json = errata.attributes.merge('pkglist' => [{'packages' => [pkg, pkg2]}])
      errata.update_from_json(json)

      assert_equal errata.reload.packages.count, pkg_count + 2
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

    def test_installable_for_systems
      errata = Erratum.installable_for_systems([@errata_server, @simple_server])
      assert_includes errata, @security
      refute_includes errata, @bugfix
      refute_includes errata, @enhancement
    end
  end
end
