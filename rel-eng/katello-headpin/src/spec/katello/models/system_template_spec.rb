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

describe SystemTemplate do

  before(:each) do
    disable_org_orchestration
    disable_product_orchestration

    @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
    @environment = KTEnvironment.create!(:name => 'env_1', :prior => @organization.locker.id, :organization => @organization)
    @provider     = @organization.redhat_provider

    @tpl1 = SystemTemplate.create!(:name => "template_1", :environment => @organization.locker)

    @prod1 = Product.create!(:cp_id => "123456", :name => "prod1", :environments => [@organization.locker], :provider => @provider)
    @prod2 = Product.create!(:cp_id => "789123", :name => "prod2", :environments => [@organization.locker], :provider => @provider)

    @organization.locker.products << @prod1
    @organization.locker.products << @prod2
  end

  let(:package_1) {{
    :id => 'package_foo_id',
    :name => 'foo',
    :package_name => 'foo',
    :version => '0.1',
    :release => '4.1',
    :epoch => '1',
    :repo_id => 'foo_repo_id',
    :product_id => 'foo_product_id',
  }}

  let(:repo_1) {{
    :name => 'foo repo'
  }}

  let(:repo_2) {{
    :name => 'foo repo clone'
  }}

  describe "package groups" do

    let(:pg_name) { RepoTestData.repo_package_groups.values[0]["name"] }
    let(:missing_pg_name) { "missing_pg" }
    let(:repo) {{
      :name => 'foo repo',
      :groupid => [
        "product:"+@prod1.cp_id.to_s,
        "env:"+@organization.locker.id.to_s,
        "org:"+@organization.name.to_s
      ]
    }}

    before :each do
      Pulp::PackageGroup.stub(:all => RepoTestData.repo_package_groups)
      Pulp::Repository.stub(:all => [repo])
    end


    describe "#add_package_group" do

      it "should make a record to the database about the assignment" do
        @tpl1.add_package_group(pg_name)
        pg = @tpl1.package_groups(true).last
        pg.should_not be_new_record
        pg.name.should == pg_name
      end

      it "should prevent from adding the same package group twice" do
        @tpl1.add_package_group(pg_name)
        lambda { @tpl1.add_package_group(pg_name) }.should raise_error(ActiveRecord::RecordInvalid)
        @tpl1.package_groups.count.should == 1
      end

      it "should raise exception if package group is missing" do
        lambda { @tpl1.add_package_group(missing_pg_name) }.should raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "#remove_package_group" do
      before do
        @tpl1.package_groups.create!(:name => pg_name)
      end

      it "should remove a record from the database about the assignment" do
        @tpl1.remove_package_group(pg_name)
        pg = @tpl1.package_groups(true).last
        pg.should be_nil
      end

      it "should raise exception if package group is missing" do
        lambda { @tpl1.remove_package_group(missing_pg_name) }.should raise_error(Errors::TemplateContentException)
      end
    end
  end


  describe "package group categories" do

    let(:pg_category_name) { RepoTestData.repo_package_group_categories.values[0]["name"] }
    let(:missing_pg_category_name) { "missing_pgc" }
    let(:repo) {{
      :name => 'foo repo',
      :groupid => [
        "product:"+@prod1.cp_id.to_s,
        "env:"+@organization.locker.id.to_s,
        "org:"+@organization.name.to_s
      ]
    }}

    before :each do
      Pulp::PackageGroupCategory.stub(:all => RepoTestData.repo_package_group_categories)
      Pulp::Repository.stub(:all => [repo])
    end

    describe "#add_pg_category" do

      it "should make a record to the database about the assignment" do
        @tpl1.add_pg_category(pg_category_name)
        pg = @tpl1.pg_categories(true).last
        pg.should_not be_new_record
        pg.name.should == pg_category_name
      end

      it "should prevent from adding the same package group twice" do
        @tpl1.add_pg_category(pg_category_name)
        lambda { @tpl1.add_pg_category(pg_category_name) }.should raise_error(ActiveRecord::RecordInvalid)
        @tpl1.pg_categories.count.should == 1
      end

      it "should raise exception if package group is missing" do
        lambda { @tpl1.add_pg_category(missing_pg_category_name) }.should raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "#remove_pg_category" do
      before do
        @tpl1.pg_categories.create!(:name => pg_category_name)
      end

      it "should remove a record from the database about the assignment" do
        @tpl1.remove_pg_category(pg_category_name)
        pg = @tpl1.pg_categories(true).last
        pg.should be_nil
      end

      it "should raise exception if package group is missing" do
        lambda { @tpl1.remove_pg_category(missing_pg_category_name) }.should raise_error(Errors::TemplateContentException)
      end
    end
  end

end
