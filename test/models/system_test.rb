# encoding: utf-8

require File.expand_path("system_base", File.dirname(__FILE__))
require 'support/host_support'

module Katello
  class SystemClassTest < SystemTestBase
    def test_uuids_to_ids
      @alabama = build(:katello_system, :alabama, :name => 'alabama man', :description => 'Alabama system', :environment => @library, :uuid => 'alabama')
      @westeros = build(:katello_system, :name => 'westeros', :description => 'Westeros system', :environment => @library, :uuid => 'westeros')
      assert @alabama.save
      assert @westeros.save
      actual_ids = System.uuids_to_ids([@alabama, @westeros].map(&:uuid))
      expected_ids = [@alabama, @westeros].map(&:id)
      assert_equal(expected_ids.size, actual_ids.size)
      assert_equal(expected_ids.to_set, actual_ids.to_set)
    end

    def test_uuids_to_ids_raises_not_found
      @alabama = build(:katello_system, :alabama, :name => 'alabama man', :description => 'Alabama system', :environment => @library, :uuid => 'alabama')
      @westeros = build(:katello_system, :name => 'westeros', :description => 'Westeros system', :environment => @library, :uuid => 'westeros')
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
      @system = build(:katello_system, :alabama, :name => 'alabama', :description => 'Alabama system', :environment => @library, :uuid => '1234')
      assert @system.save!
      refute_nil @system.content_view
      assert @system.content_view.default?
    end

    def test_create_with_content_view
      @system = build(:katello_system, :alabama, :name => 'alabama', :description => 'Alabama system', :environment => @library, :uuid => '1234')
      @system.content_view = ContentView.find(katello_content_views(:library_dev_view))
      assert @system.save
      refute @system.content_view.default?
    end

    def test_i18n_name
      @system = build(:katello_system, :alabama, :name => 'alabama', :description => 'Alabama system', :environment => @library, :uuid => '1234')
      name = "ಬoo0000"
      @system.name = name
      @system.content_view = ContentView.find(katello_content_views(:library_dev_view))
      assert @system.save!
      refute_nil System.find_by_name(name)
    end

    def test_registered_by
      User.current = User.find(users(:admin))
      @system = build(:katello_system, :alabama, :name => 'alabama', :description => 'Alabama system', :environment => @library, :uuid => '1234')
      assert @system.save!
      assert_equal User.current.name, @system.registered_by
    end
  end

  class SystemUpdateTest < SystemTestBase
    def setup
      super
      foreman_host = FactoryGirl.create(:host, :with_subscription)
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

      @system2.expects(:update_foreman_host).never
      @system2.save!
    end

    def test_fact_search
      Katello::Host::SubscriptionFacet.update_facts(@system.foreman_host, :rhsm_fact => 'rhsm_value')

      assert_includes System.search_for("facts.rhsm_fact = rhsm_value"), @system
      assert_includes System.complete_for("facts."), " facts.rhsm_fact "
    end
  end

  class SystemTest < SystemTestBase
    def setup
      super
    end

    def test_in_content_view_version_environments
      first_cvve = {:content_view_version => @system.content_view.version(@system.environment), :environments => [@system.environment]}
      second_cvve = {:content_view_version => @library_view.version(@library), :environments => [@dev]} #dummy set
      systems = System.in_content_view_version_environments([first_cvve, second_cvve])
      assert_includes systems, @system
      systems = System.in_content_view_version_environments([first_cvve])
      assert_includes systems, @system
    end

    def test_available_releases
      assert @system.available_releases.include?('6Server')
    end

    def test_save_bound_repos_by_path_empty
      refute_empty @errata_system.bound_repositories
      @errata_system.save_bound_repos_by_path!([])

      assert_empty @errata_system.bound_repositories
    end

    def test_save_bound_repos_by_path
      @repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64))

      @errata_system.bound_repositories = []
      @errata_system.save!
      @errata_system.save_bound_repos_by_path!(["/pulp/repos/#{@repo.relative_path}"])

      refute_empty @errata_system.bound_repositories
    end
  end
end
