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

require 'katello_test_helper'

module Katello
  class ContentViewFilterVersionValidatorTest < ActiveSupport::TestCase
    def self.before_suite
      models = ["Organization", "KTEnvironment", "User", "ContentView", "ContentViewVersion",
                "ContentViewEnvironment", "ContentViewFilter",
                "ContentViewPackageFilter", "ContentViewPackageFilterRule"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
    end

    def setup
      User.current = User.first
      @validator = Validators::ContentViewFilterVersionValidator.new({})
      @filter = FactoryGirl.create(:katello_content_view_package_filter)
    end

    test "fails if version and min_version provided" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id,
                                               :version => '1.0', :min_version => '1.0')
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "fails if version and max_version provided" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id,
                                               :version => '1.0', :max_version => '5.0')
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "fails if version, min_version and max_version provided" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id, :version => '1.0',
                                               :min_version => '1.0', :max_version => '5.0')
      @validator.validate(model)
      refute_empty model.errors[:base]
    end

    test "passes with version" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id, :version => '1.0')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "passes with min_version" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id, :min_version => '1.0')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "passes with max_version" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id, :max_version => '5.0')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end

    test "passes with min_version and max_version" do
      model = ContentViewPackageFilterRule.new(:content_view_filter_id => @filter.id,
                                               :min_version => '1.0', :max_version => '5.0')
      @validator.validate(model)
      assert_empty model.errors[:base]
    end
  end
end
