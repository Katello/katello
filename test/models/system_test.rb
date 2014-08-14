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

module Katello
class SystemClassTest < SystemTestBase
  def test_as_json
    options = {}
    system_json = @system.as_json options

    assert_equal 'Simple Server', system_json['name']
    assert_equal 'Dev', system_json['environment']['name']
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
end

class SystemUpdateTest < SystemTestBase
  def setup
    super
    foreman_host = Host.find(hosts(:one))
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

  def test_update_lifecycle_environment_and_content_view_updates_foreman_host
    Environment.any_instance.stubs(:content_view_puppet_environment).returns(
        ContentViewPuppetEnvironment.find(katello_content_view_puppet_environments(:dev_view_puppet_environment)))

    ContentViewPuppetEnvironment.any_instance.stubs(:puppet_environment).returns(Environment.find(environments(:testing)))

    # we are making an update to the system that should result in a change to the foreman host's puppet environment
    @system.foreman_host.expects(:save!)
    @system.save!
  end

  def test_update_lifecycle_environment_and_content_view_does_not_foreman_host
    ContentViewPuppetEnvironment.any_instance.stubs(:puppet_environment).returns(Environment.find(environments(:testing)))

    # we are making an update to the system that should NOT result in a change to the foreman host's puppet environment
    # (by default, the fixtures have the foreman host associated with a puppet environment that has no
    # content view or lifecycle environment; therefore, we should not alter it)
    @system.foreman_host.expects(:save!).never
    @system.save!
  end

  def test_update_lifecycle_environment_and_content_view_raises_error
    Environment.any_instance.stubs(:content_view_puppet_environment).returns(
        ContentViewPuppetEnvironment.find(katello_content_view_puppet_environments(:dev_view_puppet_environment)))

    # unable to locate a foreman puppet environment that is associated with the content view
    ContentViewPuppetEnvironment.any_instance.stubs(:puppet_environment).returns(nil)

    # If a puppet environment cannot be found for the lifecycle environment + content view
    # combination, then an error should be raised
    assert_raises Errors::NotFound do
      @system.save!
    end
  end

  def test_update_does_not_update_foreman_host
    foreman_host = Host.find(hosts(:one))
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

end
end
