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
require 'mocha/setup'

class ForemanGlueEnvironmentTest < MiniTest::Rails::ActiveSupport::TestCase
  def self.before_suite
    services  = ['Candlepin', 'ElasticSearch', 'Pulp']
    models    = ['Organization', 'KTEnvironment', 'ContentViewEnvironment']
    disable_glue_layers(services, models)
  end

  def setup
    ::Foreman::Environment.any_instance.stubs(:save! => true, :id => rand(100))
  end

  def test_create
    ::Foreman::Environment.any_instance.expects(:save! => true, :id => rand(100))
    assert FactoryGirl.build(:environment_with_library).save
  end

  def test_delete
    cve = FactoryGirl.create(:environment_with_library)
    ::Foreman::Environment.any_instance.expects(:destroy!).returns(true)

    assert cve.destroy
  end

  def test_update
    cve = FactoryGirl.create(:environment_with_library)
    ::Foreman::Environment.any_instance.expects(:name=).with("a different name")
    ::Foreman::Environment.any_instance.expects(:save!).returns(true)

    cve.update_attributes!(:name => "a different name")
  end
end
