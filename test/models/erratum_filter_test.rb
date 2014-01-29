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
class ErratumFilterTest < ActiveSupport::TestCase

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentView",
              "ContentViewEnvironment", "Filter", "ErratumFilter"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
  end

  def setup
    User.current = User.find(users(:admin))

    @filter = FactoryGirl.build(:erratum_filter)
    @start_date = "2013-01-01"
    @end_date = "2013-01-31"
  end

  def test_create
    assert @filter.save
  end

  def test_bad_params
    assert_bad_params(:date_range => {:boo => @start_date})
    assert_bad_params(:date_range => {:start => @start_date, :bad => 1000})
    assert_bad_params(:date_range => {:start => DateTime.now}) # has to be int not date
    #  end must be greater than start
    assert_bad_params(:date_range => {:start => @end_date, :end => @start_date})
    # errata types
    assert_bad_params(:errata_type => ['buggy'])
    assert_bad_params(:errata_type => ['bugfix', 'secure'])
    #id based params
    assert_bad_params(:units => {:id_val => '100'})
    assert_bad_params(:severity => ["low"])
  end

  def test_good_params
    assert_good_params(:date_range => {:start => @start_date})
    assert_good_params(:date_range => {:start => @start_date, :end => @end_date})
    assert_good_params(:errata_type => ['bugfix', 'security', 'enhancement'])
    assert_good_params(:units => [{:id => "foo"}, {:id => "bar"}])
    assert_good_params({:date_range => {:start => @start_date, :end => @end_date},
                        :errata_type => ['bugfix', 'security', 'enhancement']})
  end

  def test_date_params
    @filter.start_date = @start_date
    expected = {'date_range' => {:start => @start_date}}
    assert_equal(expected, @filter.parameters)
    assert_equal(@start_date, @filter.start_date)
    #test end date
    @filter.end_date = @end_date
    expected['date_range'][:end] = @end_date
    assert_equal(expected, @filter.parameters)
    assert_equal(@end_date, @filter.end_date)
  end

  def test_errata_type_params
    errata_types = ['bugfix', 'security', 'enhancement']
    @filter.errata_types = errata_types
    expected = {'errata_type' => errata_types}
    assert_equal(expected, @filter.parameters)
    assert_equal(errata_types, @filter.errata_types)
  end

  def test_updates
    assert_param_updates("end_date", @end_date) do |rule|
      assert_nil(rule[:date_range])
    end

    @filter.start_date = @start_date
    assert_param_updates("end_date", @end_date) do |rule|
      assert_nil(rule['date_range'][:end])
    end

    assert_param_updates("start_date", @start_date)  do |rule|
      assert_nil(rule['date_range'])
    end

    @filter.end_date = @end_date
    assert_param_updates("start_date", @start_date) do |rule|
      assert_nil(rule['date_range'][:start])
    end

    assert_param_updates("errata_types", ['bugfix', 'security', 'enhancement']) do |rule|
      assert_nil(rule['errata_type'])
    end
  end

  def assert_param_updates(message, initial_value)
    @filter.send("#{message}=", initial_value)
    @filter.save!
    @filter = ErratumFilter.find(@filter.id)
    assert_equal(initial_value, @filter.send("#{message}"))
    # check for nil update
    @filter.send("#{message}=", nil)
    assert @filter.save
    @filter = ErratumFilter.find(@filter.id)
    assert_nil(@filter.send("#{message}"))
    yield @filter.parameters
    @filter.parameters = {}
    @filter.save!
  end

  def assert_bad_params(params)
    @filter.parameters = params
    assert_raises(ActiveRecord::RecordInvalid) do
      @filter.save!
    end

    @filter.parameters = {:unit => "", :errata_type => ""}
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
