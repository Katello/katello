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

class FilterTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User","ContentViewEnvironment", "ContentViewDefinition"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def setup
    #User.current = User.find(users(:admin))
    @filter = FactoryGirl.build(:filter)
  end

  def after_tests
    Filter.delete_all
  end

  def test_create
    assert @filter.save
  end

  def test_bad_name
    filter = FactoryGirl.build(:filter, :name => "")
    assert filter.invalid?
    assert filter.errors.has_key?(:name)
  end

  def test_duplicate_name
    @filter.save!
    attrs = FactoryGirl.attributes_for(:filter,
                                       :name => @filter.name,
                                       :content_view_definition_id => @filter.content_view_definition_id
                                      )
    assert_raises(ActiveRecord::RecordInvalid) do
      Filter.create!(attrs)
    end
    f = Filter.create(attrs)
    refute f.persisted?
    refute f.save
  end

end
