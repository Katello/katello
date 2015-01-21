# encoding: utf-8
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

require File.expand_path("system_base", File.dirname(__FILE__))
require 'support/host_support'

module Katello
  class SystemClassTest < SystemTestBase
    def test_as_json
      options = {}
      system_json = @system.as_json options

      assert_equal 'Simple Server', system_json['name']
      assert_equal 'Library', system_json['environment']['name']
    end

    def test_uuids_to_ids
      @alabama = build(:katello_system, :alabama, :name => 'alabama man', :description => 'Alabama system', :environment => @dev, :uuid => 'alabama')
      @westeros = build(:katello_system, :name => 'westeros', :description => 'Westeros system', :environment => @dev, :uuid => 'westeros')
      assert @alabama.save
      assert @westeros.save
      actual_ids = System.uuids_to_ids([@alabama, @westeros].map(&:uuid))
      expected_ids = [@alabama, @westeros].map(&:id)
      assert_equal(expected_ids.size, actual_ids.size)
      assert_equal(expected_ids.to_set, actual_ids.to_set)
    end

    def test_uuids_to_ids_raises_not_found
      @alabama = build(:katello_system, :alabama, :name => 'alabama man', :description => 'Alabama system', :environment => @dev, :uuid => 'alabama')
      @westeros = build(:katello_system, :name => 'westeros', :description => 'Westeros system', :environment => @dev, :uuid => 'westeros')
      assert @alabama.save
      assert @westeros.save
      assert_raises Errors::NotFound do
        System.uuids_to_ids([@alabama, @westeros].map(&:uuid) + ['non_existent_uuid'])
      end
    end
  end

  class SystemCreateTest < SystemTestBase
    def setup
      super
    end

    def teardown
      @system.destroy
    end

    def test_create
      @system = build(:katello_system, :alabama, :name => 'alabama', :description => 'Alabama system', :environment => @dev, :uuid => '1234')
      assert @system.save!
      refute_nil @system.content_view
      assert @system.content_view.default?
    end

    def test_create_with_content_view
      @system = build(:katello_system, :alabama, :name => 'alabama', :description => 'Alabama system', :environment => @dev, :uuid => '1234')
      @system.content_view = ContentView.find(katello_content_views(:library_dev_view))
      assert @system.save
      refute @system.content_view.default?
    end

    def test_i18n_name
      @system = build(:katello_system, :alabama, :name => 'alabama', :description => 'Alabama system', :environment => @dev, :uuid => '1234')
      name = "ಬoo0000"
      @system.name = name
      @system.content_view = ContentView.find(katello_content_views(:library_dev_view))
      assert @system.save!
      refute_nil System.find_by_name(name)
    end

    def test_registered_by
      User.current = User.find(users(:admin))
      @system = build(:katello_system, :alabama, :name => 'alabama', :description => 'Alabama system', :environment => @dev, :uuid => '1234')
      assert @system.save!
      assert_equal User.current.name, @system.registered_by
    end
  end

  class SystemUpdateTest < SystemTestBase
    def setup
      super
      foreman_host = FactoryGirl.create(:host)
      @system.host_id = foreman_host.id
      @system.save!

      new_view = ContentView.find(katello_content_views(:library_view))
      new_lifecycle_environment = new_view.environments.first

      @system.environment = new_lifecycle_environment
      @system.content_view = new_view
    end

    def teardown
      @system.destroy
    end

    def test_update_does_not_update_foreman_host
      foreman_host = FactoryGirl.create(:host)
      @system2 = System.find(katello_systems(:simple_server2))
      @system2.host_id = foreman_host.id
      @system2.save!

      @system2.expects(:udpate_foreman_host).never
      @system2.save!
    end
  end

  class SystemTest < SystemTestBase
    def setup
      super
    end

    def test_available_releases
      assert @system.available_releases.include?('6Server')
    end

    def test_save_bound_repos_by_path_empty
      @errata_system.expects(:generate_applicability)
      @errata_system.expects(:propagate_yum_repos)
      refute_empty @errata_system.bound_repositories
      @errata_system.save_bound_repos_by_path!([])
      assert_empty @errata_system.bound_repositories
    end

    def test_save_bound_repos_by_path
      @repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64))

      @errata_system.expects(:generate_applicability)
      @errata_system.expects(:propagate_yum_repos)
      @errata_system.bound_repositories = []
      @errata_system.save!
      @errata_system.save_bound_repos_by_path!(["/pulp/repos/#{@repo.relative_path}"])

      refute_empty @errata_system.bound_repositories
    end

    def test_applicable_errata
      refute_empty @errata_system.applicable_errata
    end

    def test_available_and_applicable_errta
      assert_equal @errata_system.applicable_errata, @errata_system.installable_errata
    end

    def test_installable_errata
      lib_applicable = @errata_system.applicable_errata

      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1))
      @errata_system.bound_repositories = [@view_repo]
      @errata_system.save!

      assert_equal lib_applicable, @errata_system.applicable_errata
      refute_equal lib_applicable, @errata_system.installable_errata
      assert_include @errata_system.installable_errata, Erratum.find(katello_errata(:security))
    end

    def test_with_installable_errata
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1))
      @errata_system.bound_repositories = [@view_repo]
      @errata_system.save!

      installable = @errata_system.applicable_errata & @errata_system.installable_errata
      non_installable = @errata_system.applicable_errata - @errata_system.installable_errata
      refute_empty non_installable
      refute_empty installable
      systems = System.with_installable_errata([installable.first])
      assert_include systems, @errata_system

      systems = System.with_installable_errata([non_installable.first])
      refute systems.include?(@errata_system)
    end

    def test_with_non_installable_errata
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1))
      @errata_system.bound_repositories = [@view_repo]
      @errata_system.save!

      unavailable = @errata_system.applicable_errata - @errata_system.installable_errata
      refute_empty unavailable
      systems = System.with_non_installable_errata([unavailable.first])
      assert_include systems, @errata_system

      systems = System.with_non_installable_errata([@errata_system.installable_errata.first])
      refute systems.include?(@errata_system)
    end

    def test_available_errata_other_view
      available_in_view = @errata_system.installable_errata(@library, @library_view)
      assert_equal 1, available_in_view.length
      assert_include available_in_view, Erratum.find(katello_errata(:security))
    end
  end

  class SystemHostTest < SystemTestBase
    def setup
      super
      foreman_host = FactoryGirl.create(:host)
      @system.host_id = foreman_host.id
      @system.content_view = @library_view
      @system.environment = @library
      @system.save!
    end

    def setup_puppet_env(view, environment)
      puppet_env = ::Environment.create!(:name => 'blah')

      cvpe = view.version(environment).puppet_env(environment)
      cvpe.puppet_environment = puppet_env
      cvpe.save!
    end

    def test_update_lifecycle_environment_and_content_view_updates_foreman_host
      setup_puppet_env(@library_dev_staging_view, @dev)
      Support::HostSupport.setup_host_for_view(@system.foreman_host, @library_view, @library, true)
      @system.reload
      @system.environment = @dev
      @system.content_view = @library_dev_staging_view
      @system.save!

      host = Host.find(@system.foreman_host)
      assert_equal host.lifecycle_environment, @dev
      assert_equal host.content_view, @library_dev_staging_view
      assert_equal host.environment.content_view, @library_dev_staging_view
      assert_equal host.environment.lifecycle_environment, @dev
    end

    def test_update_content_view_mistmatch
      Support::HostSupport.setup_host_for_view(@system.foreman_host, @library_dev_staging_view, @dev, true)

      @system.foreman_host.update_column(:lifecycle_environment_id, @library) #now the host's puppet environment doesn't match its cv and lifecycle env
      @system.reload

      @system.content_view = @library_dev_staging_view
      @system.save!

      host = Host.find(@system.foreman_host)
      assert_equal host.lifecycle_environment, @library
      assert_equal host.content_view, @library_dev_staging_view
      assert_equal host.environment.content_view, @library_dev_staging_view #puppet environment is not updated
      assert_equal host.environment.lifecycle_environment, @dev
    end

    def test_update_lifecycle_environment_and_content_view_raises_error
      Support::HostSupport.setup_host_for_view(@system.foreman_host, @library_dev_staging_view, @dev, true)

      @system.content_view = @acme_default
      @system.environment = @library
      # If a puppet environment cannot be found for the lifecycle environment + content view
      # combination, then an error should be raised
      assert_raises Errors::NotFound do
        @system.save!
      end
    end
  end
end
