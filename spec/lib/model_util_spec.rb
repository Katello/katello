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

require 'katello_test_helper'

module Katello
  describe Util::Model do

    it "should return tags for organization" do
      disable_org_orchestration
      @o1 = Organization.create!(:name=>'test_org1', :label=> 'test_org1')
      @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@o1)
      @provider2 = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo2", :organization=>@o1)
      Tag.tags_for("providers", @o1.id).size.must_equal(2)
    end

    describe "labelize tests" do
      specify {Util::Model::labelize("sweet home alabama").must_equal "sweet_home_alabama"}
      specify {Util::Model::labelize("sweet-home+alabama").must_equal "sweet-home_alabama"}
      specify {Util::Model::labelize("sweet home 谷歌地球").wont_match /sweet*/}
      specify {Util::Model::labelize("sweet home 谷歌地球").must_match /^[a-zA-Z0-9\-_]+$/}
      specify {Util::Model::labelize('a' * 129).length.must_be(:<=, 128) }
    end

    describe "setup_label_from_name" do
      before(:each) do
        disable_org_orchestration
        @product = Product.new(:name => "AOL4")
        @product.stubs(:provider).returns({})
        @product.provider.stubs(:redhat_provider?).returns(true)
        @product.stubs(:provider_id).returns(1)
        lib = OpenStruct.new(:library => true)
        @product.stubs(:environments).returns([lib])
      end

      it "should populate label before validation" do
        @product.must_be :valid?
        @product.label.must_equal("AOL4")
      end
    end

  end
end
