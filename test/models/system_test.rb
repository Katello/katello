# encoding: utf-8
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

require './test/models/system_base'

class SystemClassTest < SystemTestBase
  def test_as_json
    options = {}
    system_json = @system.as_json options

    assert_equal 'Simple Server', system_json['name']
    assert_equal 'Dev', system_json['environment']['name']
  end
end

class SystemCreateTest < SystemTestBase
  def setup
    super
    @system = build(:system, :alabama, :name => 'alabama', :description => 'Alabama system', :environment => @dev, :uuid => '1234')
  end

  def teardown
    @system.destroy
  end

  def test_create
    assert @system.save!
  end

  def test_i18n_name
    name = "ಬoo0000"
    @system.name = name
    assert @system.save!
    refute_nil System.find_by_name(name)
  end
end
