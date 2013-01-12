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
require 'helpers/repo_test_data'

include OrchestrationHelper
include RepositoryHelperMethods

describe SystemTemplate, :katello => true do


  before(:each) do
    disable_org_orchestration
    disable_product_orchestration
    disable_repo_orchestration

    @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
    @environment = KTEnvironment.create!(:name=>'env_1', :label=> 'env_1', :prior => @organization.library.id, :organization => @organization)
    @provider     = @organization.redhat_provider

    @tpl1 = SystemTemplate.create!(:name => "template_1", :description => "template_1 description", :environment => @organization.library)

    @prod1 = Product.create!(:cp_id => "123456", :label => "123456", :name => "prod1", :environments => [@organization.library], :provider => @provider)
    @prod2 = Product.create!(:cp_id => "789123", :label=> "789123", :name => "prod2", :environments => [@organization.library], :provider => @provider)

    @organization.library.products << @prod1
    @organization.library.products << @prod2
  end


  describe "update template" do

    let(:repo) {Repository.new({
      :name => 'foo repo',
      :groupid => [
       "product:"+@prod1.cp_id.to_s,
        "env:"+@organization.library.id.to_s,
        "org:"+@organization.name.to_s
      ]
    })}
    let(:pack1) {{
      :name => 'package 1'
    }}
    let(:pack_groups) {[
      {
        'id' => 'pack_group1',
        'name' => 'pack_group1'
      },
      {
        'id' => 'pack_group2',
        'name' => 'pack_group2'
      }
    ]}
    let(:pack_group_categories) {[
      {
        'id' => 'pg_category1',
        'name' => 'pg_category1'
      },
      {
        'id' => 'pg_category2',
        'name' => 'pg_category2'
      }
    ]}

    before :each do

      stub_repos([repo])
      Runcible::Extensions::Repository.stub(:rpms_by_nvre => [pack1])
      Runcible::Extensions::Repository.stub(:package_groups => pack_groups.clone)
      Runcible::Extensions::Repository.stub(:package_categories => pack_group_categories.clone)



      @tpl1.set_parameter("key1", "value")
      @tpl1.add_product("prod1")
      @tpl1.add_package("pack1")
      @tpl1.add_package_group("pack_group1")
      @tpl1.add_pg_category("pg_category1")
      @tpl1.save!


      Runcible::Extensions::Repository.stub(:package_groups => pack_groups.clone)
      Runcible::Extensions::Repository.stub(:package_categories => pack_group_categories.clone)
    end


    it "should bump revision number after parameter set" do
      version_before = @tpl1.revision
      @tpl1.set_parameter("key2", "value")
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == (version_before + 1)
    end


    it "should bump revision number after parameter removal" do
      version_before = @tpl1.revision
      @tpl1.remove_parameter("key1")
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == (version_before + 1)
    end

    #bz 799149
    #it "should bump revision number after product added" do
    #  version_before = @tpl1.revision
    #  @tpl1.add_product("prod2")
    #  @tpl1.save!
    #  version_after  = @tpl1.revision
    #
    #  version_after.should == (version_before + 1)
    #end
    #
    #
    #it "should bump revision number after product removal" do
    #  version_before = @tpl1.revision
    #  @tpl1.remove_product("prod1")
    #  @tpl1.save!
    #  version_after  = @tpl1.revision
    #
    #  version_after.should == (version_before + 1)
    #end


    it "should bump revision number after package added" do
      version_before = @tpl1.revision
      @tpl1.add_package("pack2")
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == (version_before + 1)
    end


    it "should bump revision number after package removal" do
      version_before = @tpl1.revision
      @tpl1.remove_package("pack1")
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == (version_before + 1)
    end


    it "should bump revision number after package group added" do
      version_before = @tpl1.revision
      @tpl1.add_package_group("pack_group2")
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == (version_before + 1)
    end


    it "should bump revision number after package group removal" do
      version_before = @tpl1.revision
      @tpl1.remove_package_group("pack_group1")
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == (version_before + 1)
    end


    it "should bump revision number after package group category added" do
      version_before = @tpl1.revision
      @tpl1.add_pg_category("pg_category2")
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == (version_before + 1)
    end


    it "should bump revision number after package group category removal" do
      version_before = @tpl1.revision
      @tpl1.remove_pg_category("pg_category1")
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == (version_before + 1)
    end


    it "should not bump revision number when nothing changed" do
      version_before = @tpl1.revision
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == version_before
    end


    it "should not bump revision number when only name and description" do
      version_before = @tpl1.revision
      @tpl1.name        = @tpl1.name + "_changed"
      @tpl1.description = @tpl1.description + "_changed"
      @tpl1.save!
      version_after  = @tpl1.revision

      version_after.should == version_before
    end

  end

end
