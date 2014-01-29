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

require 'katello_test_helper'

module Katello
class PackageGroupFilterTest < ActiveSupport::TestCase

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentView",
              "ContentViewEnvironment", "Filter", "PackageGroupFilter"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def setup
    User.current = User.find(users(:admin))
    @filter = FactoryGirl.build(:package_group_filter)
  end

  def test_create
    assert @filter.save
  end

  def test_bad_params
    assert_bad_params(:foo => {:boo => 100})
    assert_bad_params(:units => "cool")
    assert_bad_params(:units => [{:name => "foo"}, {:min_version => "3.0"}]) # no name
  end

  def test_good_params
    assert_good_params(:units => [{:name => "foo"}, {:name => "bar"}])
  end

  def assert_bad_params(params)
    @filter.parameters = params
    assert_raises(ActiveRecord::RecordInvalid) do
      @filter.save!
    end
  end

  def assert_good_params(params)
    @filter.parameters = params
    assert @filter.save
  end

end
end
