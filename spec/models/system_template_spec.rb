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

    @prod1 = Product.create!(:name => "prod1", :environments => [@organization.locker], :provider => @provider)
    @prod2 = Product.create!(:name => "prod2", :environments => [@organization.locker], :provider => @provider)

    @organization.locker.products << @prod1
    @organization.locker.products << @prod2
  end

  describe "create template" do

    it "should create empty template" do
      @empty_tpl = SystemTemplate.create!(:name => "template_2", :environment => @organization.locker)

      @empty_tpl.name.should == "template_2"
      @empty_tpl.created_at.should_not be_nil
      @organization.locker.system_templates.should include @empty_tpl
    end

    it "should create empty template with parent" do
      @tpl_with_parent = SystemTemplate.create!(:name => "template_2", :environment => @organization.locker, :parent => @tpl1)

      @tpl_with_parent.name.should == "template_2"
      @tpl_with_parent.created_at.should_not be_nil
      @tpl_with_parent.parent.should == @tpl1
      @organization.locker.system_templates.should include @tpl_with_parent
    end

    it "should fail when creating template with invalid parent" do
      @tpl_in_other_env = SystemTemplate.create!(:name => "another_template", :environment => @environment)

      lambda {SystemTemplate.create!(:name => "template_2", :environment => @organization.locker, :parent => @tpl_in_other_env)}.should raise_error
    end

    it  "should save valid product and packages" do
      @valid_tpl = SystemTemplate.new(:name => "valid_template", :environment => @organization.locker)

      @pack1 = SystemTemplatePackage.new(:package_name => "pack1")
      @pack1.stub(:to_package).and_return {}
      @pack1.stub(:valid?).and_return true

      @valid_tpl.products << @prod1
      @valid_tpl.packages << @pack1

      lambda {@valid_tpl.save!}.should_not raise_error
      @valid_tpl.created_at.should_not be_nil
    end

    it "should fail with invalid content" do
      @pack1 = SystemTemplatePackage.new(:package_name => "pack1")
      @pack1.stub(:to_package).and_return {}
      @pack1.stub(:valid?).and_return false

      @tpl1.packages << @pack1

      lambda {@tpl1.save!}.should raise_error
    end

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

  describe "promote template" do

    before :each do
      @from_env = @organization.locker
      @to_env = @environment
    end

    it "should promote only products that haven't been promoted yet" do
      @prod1.environments << @to_env
      @tpl1.products << @prod1
      @tpl1.products << @prod2
      @tpl1.stub(:copy_to_env)

      @prod1.stub(:promote).and_return([])
      @prod2.stub(:promote).and_return([])

      @prod1.should_not_receive(:promote)
      @prod2.should_receive(:promote)

      @tpl1.promote(@from_env, @to_env)
    end

    it "should promote packages picked for promotion" do

      @tpl1.environment.stub(:find_packages_by_name).and_return([package_1])
      @tpl1.packages << SystemTemplatePackage.new(:package_name => 'foo', :system_template => @tpl1)
      @tpl1.stub(:copy_to_env)
      @tpl1.stub(:get_promotable_packages).and_return([package_1])

      repo = Glue::Pulp::Repo.new(repo_1)
      clone = Glue::Pulp::Repo.new(repo_2)
      repo.stub(:is_cloned_in?).and_return(true)
      repo.stub(:get_clone).and_return(clone)

      Glue::Pulp::Repo.stub(:find).with(package_1[:repo_id]).and_return(repo)
      clone.should_receive(:add_packages).with([package_1[:id]])

      @tpl1.promote(@from_env, @to_env)
    end

    it "should promote products that are required by packages and haven't been promoted yet" do
      @tpl1.environment.stub(:find_packages_by_name).and_return([package_1])
      @tpl1.packages << SystemTemplatePackage.new(:package_name => 'foo', :system_template => @tpl1)
      @tpl1.stub(:copy_to_env)
      @tpl1.stub(:get_promotable_packages).and_return([package_1])

      repo = Glue::Pulp::Repo.new(repo_1)
      repo.stub(:is_cloned_in?).and_return(false)

      Glue::Pulp::Repo.stub(:find).with(package_1[:repo_id]).and_return(repo)
      Product.stub(:find_by_cp_id).with(package_1[:product_id]).and_return(@prod1)

      @prod1.should_receive(:promote).with(@from_env, @to_env).and_return([])
      clone.should_not_receive(:add_packages)

      @tpl1.promote(@from_env, @to_env)
    end


    describe "selecting packages for promotion" do

      it "should pick the latest when the package was specified by name" do
        tpl_pack = SystemTemplatePackage.new(package_1.slice(:package_name))
        expected = [package_1]

        @to_env.should_receive(:find_packages_by_name).with(package_1[:name]).and_return([])
        @from_env.should_receive(:find_latest_package_by_name).with(package_1[:name]).and_return(package_1)
        @from_env.should_receive(:find_packages_by_nvre).with(package_1[:name], package_1[:version], package_1[:release], package_1[:epoch]).and_return([package_1])

        @tpl1.get_promotable_packages(@from_env, @to_env, tpl_pack).should == expected
      end

      it "should return empty list when a package with the same name is already in the next environment" do
        tpl_pack = SystemTemplatePackage.new(package_1.slice(:package_name))
        expected = []

        @to_env.should_receive(:find_packages_by_name).with(package_1[:name]).and_return([package_1])

        @tpl1.get_promotable_packages(@from_env, @to_env, tpl_pack).should == expected
      end

      it "should pick the specified nvre" do
        tpl_pack = SystemTemplatePackage.new(package_1.slice(:package_name, :version, :release, :epoch))
        expected = [package_1]

        @to_env.should_receive(:find_packages_by_nvre).with(package_1[:name], package_1[:version], package_1[:release], package_1[:epoch]).and_return([])
        @from_env.should_receive(:find_packages_by_nvre).with(package_1[:name], package_1[:version], package_1[:release], package_1[:epoch]).and_return([package_1])

        @tpl1.get_promotable_packages(@from_env, @to_env, tpl_pack).should == expected
      end

      it "should return empty list when the nvre is in the next environment" do
        tpl_pack = SystemTemplatePackage.new(package_1.slice(:package_name, :version, :release, :epoch))
        expected = []

        @to_env.should_receive(:find_packages_by_nvre).with(package_1[:name], package_1[:version], package_1[:release], package_1[:epoch]).and_return([package_1])

        @tpl1.get_promotable_packages(@from_env, @to_env, tpl_pack).should == expected
      end
    end


    it "should clone the template to the next environment" do
      @tpl1.should_receive(:copy_to_env).with(@environment)

      @tpl1.promote(@organization.locker, @environment)
    end

  end


  describe "import & export template" do

    before(:each) do
      @import="
{
  'name': 'Web Server',
  'revision': 1,
  'products': [
    'prod_a1',
    'prod_a2'
  ],
  'packages': [
    'walrus'
  ],
  'parameters': {
    'attr1': 'val1',
    'attr2': 'val2'
  },
  'package_groups': [
    {'id': 'pg-123', 'repo': 'repo-123'},
    {'id': 'pg-456', 'repo': 'repo-123'}
  ],
  'package_group_categories': [
    {'id': 'pgc-123', 'repo': 'repo-123'},
    {'id': 'pgc-456', 'repo': 'repo-123'}
  ]
}
"
    end

    it "should import template content" do
      @import_tpl = SystemTemplate.new(:environment => @organization.locker)

      @import_tpl.should_receive(:add_product).once.with('prod_a1').and_return nil
      @import_tpl.should_receive(:add_product).once.with('prod_a2').and_return nil
      @import_tpl.should_receive(:add_package).once.with('walrus').and_return nil
      @import_tpl.should_receive(:add_package_group).once.with({:id => 'pg-123', :repo => 'repo-123'}).and_return nil
      @import_tpl.should_receive(:add_package_group).once.with({:id => 'pg-456', :repo => 'repo-123'}).and_return nil
      @import_tpl.should_receive(:add_pg_category).once.with({:id => 'pgc-123', :repo => 'repo-123'}).and_return nil
      @import_tpl.should_receive(:add_pg_category).once.with({:id => 'pgc-456', :repo => 'repo-123'}).and_return nil


      @import_tpl.string_import(@import)

      @import_tpl.name.should == "Web Server"
      @import_tpl.revision.should == 1
      @import_tpl.parameters['attr1'].should == 'val1'
      @import_tpl.parameters['attr2'].should == 'val2'
    end

    it "should export template content" do

      @export_tpl = SystemTemplate.new(:name => "export_template", :environment => @organization.locker)
      @export_tpl.stub(:products).and_return [@prod1, @prod2]
      @export_tpl.stub(:packages).and_return [mock({:package_name => 'xxx'})]
      @export_tpl.stub(:parameters_json).and_return "{}"
      @export_tpl.stub(:package_groups).and_return [SystemTemplatePackGroup.new({:package_group_id => 'xxx', :repo_id => "repo-123" })]
      @export_tpl.stub(:pg_categories).and_return [SystemTemplatePgCategory.new({:pg_category_id => 'xxx', :repo_id => "repo-456"})]

      str = @export_tpl.string_export
      json = ActiveSupport::JSON.decode(str)
      json['products'].size.should == 2
      json['packages'].size.should == 1
      json['package_groups'].size.should == 1
      json['package_group_categories'].size.should == 1
    end

  end


  describe "destroy template" do

    it "should fail when deleting template with children" do
      @tpl2 = SystemTemplate.create!(:name => "template_2", :environment => @organization.locker, :parent => @tpl1)

      lambda {@tpl1.destroy}.should raise_error
    end

    it "should delete all content" do
      @pack1 = SystemTemplatePackage.new(:package_name => "pack1")
      @pack1.stub(:to_package).and_return {}
      @pack1.stub(:valid?).and_return true

      @tpl1.products << @prod1
      @tpl1.packages << @pack1
      @tpl1.save!

      id = @tpl1.id
      @tpl1.destroy

      SystemTemplatePackage.find_by_system_template_id(id).should == nil
    end

  end


  describe "package groups" do
    before { Pulp::PackageGroup.stub(:all => RepoTestData.repo_package_groups) }
    let(:pg_attributes) { {:repo_id => "repo-123", :id => RepoTestData.repo_package_groups.values.first["id"]} }
    let(:missing_pg_attributes) { {:repo_id => "repo-123", :id => "missing-id"} }

    describe "#add_package_group" do

      it "should make a record to the database about the assignment" do
        @tpl1.add_package_group(pg_attributes)
        pg = @tpl1.package_groups(true).last
        pg.should_not be_new_record
        pg.repo_id.should == pg_attributes[:repo_id]
        pg.package_group_id.should == pg_attributes[:id]
      end

      it "should prevent from adding the same package group twice" do
        @tpl1.add_package_group(pg_attributes)
        lambda { @tpl1.add_package_group(pg_attributes) }.should raise_error(ActiveRecord::RecordInvalid)
        @tpl1.package_groups.count.should == 1
      end

      it "should raise exception if package group is missing" do
        lambda { @tpl1.add_package_group(missing_pg_attributes) }.should raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "#remove_package_group" do
      before do
        @tpl1.package_groups.create!(:repo_id => pg_attributes[:repo_id], :package_group_id => pg_attributes[:id])
      end

      it "should remove a record from the database about the assignment" do
        @tpl1.remove_package_group(pg_attributes)
        pg = @tpl1.package_groups(true).last
        pg.should be_nil
      end

      it "should raise exception if package group is missing" do
        lambda { @tpl1.remove_package_group(missing_pg_attributes) }.should raise_error(Errors::TemplateContentException)
      end
    end
  end


  describe "package group categories" do
    before { Pulp::PackageGroupCategory.stub(:all => RepoTestData.repo_package_group_categories) }
    let(:pg_cat_attributes) { {:repo_id => "repo-123", :id => RepoTestData.repo_package_group_categories.values.first["id"]} }
    let(:missing_pg_cat_attributes) { {:repo_id => "repo-123", :id => "missing-id"} }

    describe "#add_pg_category" do

      it "should make a record to the database about the assignment" do
        @tpl1.add_pg_category(pg_cat_attributes)
        pg = @tpl1.pg_categories(true).last
        pg.should_not be_new_record
        pg.repo_id.should == pg_cat_attributes[:repo_id]
        pg.pg_category_id.should == pg_cat_attributes[:id]
      end

      it "should prevent from adding the same package group twice" do
        @tpl1.add_pg_category(pg_cat_attributes)
        lambda { @tpl1.add_pg_category(pg_cat_attributes) }.should raise_error(ActiveRecord::RecordInvalid)
        @tpl1.pg_categories.count.should == 1
      end

      it "should raise exception if package group is missing" do
        lambda { @tpl1.add_pg_category(missing_pg_cat_attributes) }.should raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "#remove_pg_category" do
      before do
        @tpl1.pg_categories.create!(:repo_id => pg_cat_attributes[:repo_id], :pg_category_id => pg_cat_attributes[:id])
      end

      it "should remove a record from the database about the assignment" do
        @tpl1.remove_pg_category(pg_cat_attributes)
        pg = @tpl1.pg_categories(true).last
        pg.should be_nil
      end

      it "should raise exception if package group is missing" do
        lambda { @tpl1.remove_pg_category(missing_pg_cat_attributes) }.should raise_error(Errors::TemplateContentException)
      end
    end
  end

end
