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
  class ContentViewPuppetModuleValidatorTest < ActiveSupport::TestCase

    def setup
      Katello::PuppetModule.stubs(:exists?).returns(true)
      @base_record = { :errors => { :base => [] }, :content_view => OpenStruct.new(:puppet_repos => []) }
      @validator = Validators::ContentViewPuppetModuleValidator.new(:attributes => [:name])
    end

    test "fails if both name and uuid blank" do
      @model = OpenStruct.new(:errors => {:base => []})
      @validator.validate(@model)

      refute_empty @model.errors[:base]
    end

    test "passes if name provided" do
      @model = OpenStruct.new(@base_record.merge(:name => "module name"))
      @validator.validate(@model)

      assert_empty @model.errors[:base]
    end

    test "passes if name and author provided" do
      @model = OpenStruct.new(@base_record.merge(:name => "module name", :author => "module author"))
      @validator.validate(@model)
      assert_empty @model.errors[:base]
    end

    test "passes if uuid provided" do
      @model = OpenStruct.new(@base_record.merge(:uuid => "3bd47a52-0847-42b5-90ff-206307b48b22"))
      @validator.validate(@model)

      assert_empty @model.errors[:base]
    end

    test "fails if module does not exists" do
      @model = OpenStruct.new(@base_record.merge(:name => "module name", :author => "module author"))
      Katello::PuppetModule.stubs(:exists?).returns(false)
      @validator.validate(@model)

      refute_empty @model.errors[:base]
    end

    test "passes if the module does exist" do
      @model = OpenStruct.new(@base_record.merge(:name => "module name", :author => "module author"))
      @validator.validate(@model)

      assert_empty @model.errors[:base]
    end
  end
end
