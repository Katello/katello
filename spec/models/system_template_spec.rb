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

    @tpl1 = SystemTemplate.create!(:name => "template_1", :environment => @organization.library)

    @tpl1_clone = mock(SystemTemplate)
    @tpl1_clone.stub(:save!)
    @tpl1_clone.stub(:save)

    @prod1 = Product.create!(:cp_id => "123456",:label=>"123456", :name => "prod1", :environments => [@organization.library], :provider => @provider)
    @prod2 = Product.create!(:cp_id => "789123", :label => "789123", :name => "prod2", :environments => [@organization.library], :provider => @provider)

    @organization.library.products << @prod1
    @organization.library.products << @prod2
  end

  describe "create template" do

    it "should create empty template" do
      @empty_tpl = SystemTemplate.create!(:name => "template_2", :environment => @organization.library)

      @empty_tpl.name.should == "template_2"
      @empty_tpl.created_at.should_not be_nil
      @organization.library.system_templates.should include @empty_tpl
    end

    it "should create empty template with parent" do
      @tpl_with_parent = SystemTemplate.create!(:name => "template_2", :environment => @organization.library, :parent => @tpl1)

      @tpl_with_parent.name.should == "template_2"
      @tpl_with_parent.created_at.should_not be_nil
      @tpl_with_parent.parent.should == @tpl1
      @organization.library.system_templates.should include @tpl_with_parent
    end

    it "should fail when creating template with invalid parent" do
      @tpl_in_other_env = SystemTemplate.create!(:name => "another_template", :environment => @environment)

      lambda {SystemTemplate.create!(:name => "template_2", :environment => @organization.library, :parent => @tpl_in_other_env)}.should raise_error
    end

    it  "should save valid product and packages" do
      @valid_tpl = SystemTemplate.new(:name => "valid_template", :environment => @organization.library)

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
      @from_env = @organization.library
      @to_env = @environment
    end

    it "should promote only products that haven't been promoted yet" do
      @prod1.environments << @to_env
      @tpl1.products << @prod1
      @tpl1.products << @prod2

      @prod1.stub(:promote).and_return([])
      @prod2.stub(:promote).and_return([])

      @prod1.should_not_receive(:promote)
      @prod2.should_receive(:promote)

      @tpl1.stub(:copy_to_env).and_return(@tpl1_clone)
      @tpl1.promote(@from_env, @to_env)
    end

    it "should promote packages picked for promotion" do

      @tpl1.environment.stub(:find_packages_by_name).and_return([package_1])
      @tpl1.packages << SystemTemplatePackage.new(:package_name => 'foo', :system_template => @tpl1)
      @tpl1.stub(:get_promotable_packages).and_return([package_1])

      repo = Repository.new(repo_1)
      clone = Repository.new(repo_2)
      repo.stub(:is_cloned_in?).and_return(true)
      repo.stub(:get_clone).and_return(clone)

      Repository.stub(:find).with(package_1[:repo_id]).and_return(repo)
      Repository.stub(:find_by_pulp_id).with(package_1[:repo_id]).and_return(repo)
      clone.should_receive(:add_packages).with([package_1[:id]])

      @tpl1.stub(:copy_to_env).and_return(@tpl1_clone)
      @tpl1.promote(@from_env, @to_env)
    end

    it "should promote products that are required by packages and haven't been promoted yet" do
      @tpl1.environment.stub(:find_packages_by_name).and_return([package_1])
      @tpl1.packages << SystemTemplatePackage.new(:package_name => 'foo', :system_template => @tpl1)
      @tpl1.stub(:get_promotable_packages).and_return([package_1])

      repo = Repository.new(repo_1)
      repo.stub(:is_cloned_in?).and_return(false)

      Repository.stub(:find).with(package_1[:repo_id]).and_return(repo)
      Repository.stub(:find_by_pulp_id).with(package_1[:repo_id]).and_return(repo)
      Product.stub(:find_by_cp_id).with(package_1[:product_id]).and_return(@prod1)

      @prod1.should_receive(:promote).with(@from_env, @to_env).and_return([])
      clone.should_not_receive(:add_packages)

      @tpl1.stub(:copy_to_env).and_return(@tpl1_clone)
      @tpl1.promote(@from_env, @to_env)
    end


    describe "selecting packages for promotion" do

      it "should pick the latest when the package was specified by name" do
        tpl_pack = SystemTemplatePackage.new(package_1.slice(:package_name))
        expected = [package_1]

        @to_env.should_receive(:find_packages_by_name).with(package_1[:name]).and_return([])
        @from_env.should_receive(:find_latest_packages_by_name).with(package_1[:name]).and_return([package_1])

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
      @tpl1.should_receive(:copy_to_env).with(@environment).and_return(@tpl1_clone)

      @tpl1.promote(@organization.library, @environment)
    end

    it "should keep the content of the cloned template" do

      @prod1.environments << @to_env
      @tpl1.products << @prod1
      @tpl1.revision = 83

      @tpl1.stub(:promote_products)
      @tpl1.stub(:promote_packages)

      @tpl1.promote(@from_env, @to_env)
      cloned_tpl = @to_env.system_templates.first
      cloned_tpl.export_as_json.should == @tpl1.export_as_json
    end

  end


  describe "import & export template" do

    before(:each) do
      @import='{
        "name": "Web Server",
        "revision": 1,
        "products": [
          "prod_a1",
          "prod_a2"
        ],
        "packages": [
          "walrus"
        ],
        "parameters": {
          "attr1": "val1",
          "attr2": "val2"
        },
        "package_groups": [
          "pg-123",
          "pg-456"
        ],
        "package_group_categories": [
          "pgc-123",
          "pgc-456"
        ],
        "distributions": [
          "ks-distro"
        ]
      }'
    end

    it "should import template content" do
      @import_tpl = SystemTemplate.new(:environment => @organization.library)

      #bz 799149
      #@import_tpl.should_receive(:add_product).once.with('prod_a1').and_return nil
      #@import_tpl.should_receive(:add_product).once.with('prod_a2').and_return nil
      @import_tpl.should_receive(:add_package).once.with('walrus').and_return nil
      @import_tpl.should_receive(:add_package_group).once.with('pg-123').and_return nil
      @import_tpl.should_receive(:add_package_group).once.with('pg-456').and_return nil
      @import_tpl.should_receive(:add_pg_category).once.with('pgc-123').and_return nil
      @import_tpl.should_receive(:add_pg_category).once.with('pgc-456').and_return nil
      @import_tpl.should_receive(:add_distribution).once.with('ks-distro').and_return nil


      @import_tpl.string_import(@import)

      @import_tpl.name.should == "Web Server"
      @import_tpl.revision.should == 1
      @import_tpl.parameters['attr1'].should == 'val1'
      @import_tpl.parameters['attr2'].should == 'val2'
    end

    it "should export template content" do

      @export_tpl = SystemTemplate.new(:name => "export_template", :environment => @organization.library)
      @export_tpl.stub(:products).and_return [@prod1, @prod2]
      @export_tpl.stub(:packages).and_return [mock({:package_name => 'xxx', :nvrea => 'xxx'})]
      @export_tpl.stub(:parameters_json).and_return "{}"
      @export_tpl.stub(:package_groups).and_return [SystemTemplatePackGroup.new({:name => 'xxx'})]
      @export_tpl.stub(:pg_categories).and_return [SystemTemplatePgCategory.new({:name => 'xxx'})]
      @export_tpl.stub(:distributions).and_return [SystemTemplateDistribution.new({:distribution_pulp_id=> 'xxx'})]

      str = @export_tpl.export_as_json
      json = ActiveSupport::JSON.decode(str)
      #bz 799149
      #json['products'].size.should == 2
      json['packages'].size.should == 1
      json['package_groups'].size.should == 1
      json['package_group_categories'].size.should == 1
      json['distributions'].size.should == 1
    end

  end


  describe "destroy template" do

    it "should fail when deleting template with children" do
      @tpl2 = SystemTemplate.create!(:name => "template_2", :environment => @organization.library, :parent => @tpl1)

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

  describe "packages" do

    let(:nvrea) { "name-ver.si.on-relea.se.x86_64.rpm" }
    let(:nvrea_package_params) do
      { :package_name  => "name", :version => "ver.si.on", :release => "relea.se", :epoch => nil, :arch => "x86_64"}
    end

    let(:nvre) { "name-ver.si.on-relea.se" }
    let(:nvre_package_params) do
      { :package_name  => "name", :version => "ver.si.on", :release => "relea.se", :epoch => nil, :arch => nil }
    end

    let(:plain_name) { "name" }
    let(:plain_name_package_params) do
      { :package_name  => "name" }
    end

    describe "#add_package" do
      it "should accept plain name" do
        @tpl1.packages.should_receive(:create!).with(plain_name_package_params)
        @tpl1.add_package(plain_name)
      end
    end

    describe "#remove_package" do
      before { @tpl1.packages.stub(:delete) }
      it "should accept plain name" do
        @tpl1.packages.should_receive(:find).with(:first, :conditions => plain_name_package_params)
        @tpl1.remove_package(plain_name)
      end

      it "should delete found package from template" do
        pack = mock(SystemTemplatePackage)
        @tpl1.packages.stub(:find => pack)
        @tpl1.packages.should_receive(:delete).with(pack)
        @tpl1.remove_package(plain_name)
      end
    end
  end

  describe "package groups" do

    let(:pg_name) { RepoTestData.repo_package_groups[0]["name"] }
    let(:missing_pg_name) { "missing_pg" }
    let(:repo) {Repository.new({
      :name => 'foo repo',
      :groupid => [
        "product:"+@prod1.cp_id.to_s,
        "env:"+@organization.library.id.to_s,
        "org:"+@organization.name.to_s
      ]
    })}

    before :each do
      Runcible::Extensions::Repository.stub(:package_groups => RepoTestData.repo_package_groups)
      stub_repos([repo])
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
    let(:pg_category_name) { RepoTestData.repo_package_group_categories[0]["name"] }
    let(:missing_pg_category_name) { "missing_pgc" }
    let(:repo) {Repository.new({
      :name => 'foo repo',
      :groupid => [
        "product:"+@prod1.cp_id.to_s,
        "env:"+@organization.library.id.to_s,
        "org:"+@organization.name.to_s
      ]
    })}

    before :each do
      Runcible::Extensions::Repository.stub(:package_categories => RepoTestData.repo_package_group_categories)
      stub_repos([repo])
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

  describe "distributions" do

    let(:distribution) { RepoTestData.repo_distributions["id"] }
    let(:repo) {Repository.new({
      :name => 'foo repo',
      :pulp_id => 'foo repo',
      :id => 'foo repo',
    })}

    before :each do
      Runcible::Extensions::Repository.stub(:distributions => [RepoTestData.repo_distributions])
      stub_repos([repo])
    end

    describe "#add_distribution" do


      it "should make a record to the database about the assignment" do
        @tpl1.add_distribution(distribution)
        d = @tpl1.distributions(true).last
        d.should_not be_new_record
        d.distribution_pulp_id.should == distribution
      end

      it "should prevent from adding the same package group twice" do
        @tpl1.add_distribution(distribution)
        lambda { @tpl1.add_distribution(distribution) }.should raise_error(ActiveRecord::RecordInvalid)
        @tpl1.distributions.count.should == 1
      end
    end

    describe "#remove_distribution" do
      before do
        @tpl1.distributions.create!(:distribution_pulp_id=> distribution)
      end

      it "should remove a record from the database about the assignment" do
        @tpl1.remove_distribution(distribution)
        d = @tpl1.distributions(true).last
        d.should be_nil
      end
    end
  end

  describe "TDL export" do

    subject { Nokogiri.parse(@tpl1.export_as_tdl) }

    let(:distribution) { RepoTestData.repo_distributions["id"] }

    describe "repositories and distributions", :katello => true do
      before do
        disable_repo_orchestration
        Repository.stub(:distributions => [RepoTestData.repo_distributions])
        Runcible::Extensions::Repository.stub(:distributions).and_return([RepoTestData.repo_distributions])
        Runcible::Extensions::Distribution.stub(:find_all).and_return([RepoTestData.repo_distributions])

        stub_repos([Repository.new(RepoTestData::REPO_PROPERTIES)])
        @prod1.stub(:repos => [Repository.new(RepoTestData::REPO_PROPERTIES)])

        @tpl1.products << @prod1
        @tpl1.add_distribution(distribution)
        # simulate another env
        @tpl1.stub(:environment => @organization.environments.new(:name => "Dev"))
      end

      it "should contain repos referencing to pulp repositories" do
        repo = subject.xpath("/template/repositories/repository").first
        repo["name"].should == "repo"
        repo.xpath("./url").text.should =~ /repos\/ACME_Corporation\/Library\/zoo\/base$/
      end

      it "should contain 'persisted' tag" do
        subject.xpath("/template/repositories/repository/persisted").text.should == "No"
      end

      it "should contain 'clientcert' and 'clientkey' tags" do
        subject.xpath("/template/repositories/repository/clientcert").text.should_not == nil
        subject.xpath("/template/repositories/repository/clientkey").text.should_not == nil
      end

      it "name, version, arch should not be nil" do
        subject.xpath("/template/os/name").text.should_not == nil
        subject.xpath("/template/os/version").text.should_not == nil
        subject.xpath("/template/os/arch").text.should_not == nil
      end

      it "url should be set" do
        subject.xpath("/template/os/install/url").text.should == "https://localhost/pulp/ks/ACME_Corporation/Dev/isos/xxx/"
      end

      it "should be valid" do
        @tpl1.validate_tdl.should be_true
      end

      it_should_behave_like "valid tdl"

      it "should not be valid without a product" do
        @tpl1.products.clear
        expect { @tpl1.validate_tdl }.to raise_error(Errors::TemplateValidationException)
      end

      it "should not be valid without a distribution" do
        @tpl1.distributions.clear
        expect { @tpl1.validate_tdl }.to raise_error(Errors::TemplateValidationException)
      end
    end
  end

end
