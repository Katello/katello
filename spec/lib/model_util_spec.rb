# encoding: utf-8

#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'

describe Util::Model do

  it "should work with tag" do
    Util::Model.table_to_class("tag").class_name.should match("Tag")
  end

  it "should work with kt_environment" do
    Util::Model.table_to_class("kt_environment").class_name.should match("KTEnvironment")
  end

  it "should return tags for organization" do
    disable_org_orchestration
    @o1 = Organization.create!(:name=>'test_org1', :label=> 'test_org1')
    @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@o1)
    @provider2 = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo2", :organization=>@o1)
    Tag.tags_for("providers", @o1.id).size.should be(2)
  end

  context "labelize tests" do
    specify {Util::Model::labelize("sweet home alabama").should == "sweet_home_alabama"}
    specify {Util::Model::labelize("sweet-home+alabama").should == "sweet-home_alabama"}
    specify {Util::Model::labelize("sweet home 谷歌地球").should_not  =~ /sweet*/}
    specify {Util::Model::labelize("sweet home 谷歌地球").should  =~ /^[a-zA-Z0-9\-_]+$/}
  end

  context "setup_label_from_name" do
    before(:each) do
      disable_org_orchestration
      @product = Product.new(:name => "AOL4")
      @product.stub(:provider).and_return(mock_model("Provider"))
      lib = mock_model("KTEnvironment", :library => true)
      @product.stub(:environments).and_return([lib])
    end

    it "should populate label before validation" do
      @product.should be_valid
      @product.label.should eql("AOL4")
    end
  end

end
