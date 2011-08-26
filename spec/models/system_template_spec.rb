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

include OrchestrationHelper

describe SystemTemplate do

  before(:each) do
    disable_org_orchestration
    disable_product_orchestration

    @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
    @environment = KTEnvironment.create!(:name => 'env_1', :prior => @organization.locker.id, :organization => @organization)
    @provider     = Provider.create!(:organization => @organization, :name => 'provider', :repository_url => "https://something.url", :provider_type => Provider::REDHAT)

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

    it  "should save valid product, packages and errara" do
      @valid_tpl = SystemTemplate.new(:name => "valid_template", :environment => @organization.locker)

      @pack1 = SystemTemplatePackage.new(:package_name => "pack1")
      @pack1.stub(:to_package).and_return {}
      @pack1.stub(:valid?).and_return true

      @err1 = SystemTemplateErratum.new(:erratum_id => "err1")
      @err1.stub(:to_erratum).and_return {}
      @err1.stub(:valid?).and_return true

      @valid_tpl.products << @prod1
      @valid_tpl.packages << @pack1
      @valid_tpl.errata << @err1


      lambda {@valid_tpl.save!}.should_not raise_error
      @valid_tpl.created_at.should_not be_nil
    end

    it "should fail with invalid content" do
      @pack1 = SystemTemplatePackage.new(:package_name => "pack1")
      @err1  = SystemTemplateErratum.new(:erratum_id => "err1")

      @tpl1.packages << @pack1
      @tpl1.errata   << @err1

      lambda {@tpl1.save!}.should raise_error
    end

  end


  describe "promote template" do

    before(:each) do
      @changeset = Changeset.create(:environment => @tpl1.environment)
      @changeset.stub(:promote)

      Changeset.stub!(:create!).and_return(@changeset)
    end

    it "should create changeset in the correct environment" do
      Changeset.should_receive(:create!).once.with(hash_including(:environment => @environment, :state => Changeset::REVIEW)).and_return(@changeset)
      @tpl1.promote
    end

    it "should raise an error if template's environment is the last in the chain of promotion" do
      tpl = SystemTemplate.create!(:name => "template_2", :environment => @environment)
      lambda { tpl.promote }.should raise_error
    end

    it "should promote also the parents content" do
      @tpl2 = SystemTemplate.create!(:name => "template_2", :environment => @organization.locker, :parent => @tpl1)
      @tpl2.products << @prod2
      @tpl2.save!

      @tpl1.products << @prod1
      @tpl1.save!

      @tpl1.should_receive(:copy_to_env).and_return {}
      @tpl2.should_receive(:copy_to_env).and_return {}
      @changeset.should_receive(:promote).once

      @tpl2.promote

      @changeset.products.should include @prod1
      @changeset.products.should include @prod2
    end

    it "should promote its products" do
      @tpl1.products << @prod1
      @tpl1.save

      @tpl1.should_receive(:copy_to_env).and_return {}

      @changeset.should_receive(:promote).once

      @tpl1.promote
      @changeset.products.should include @prod1
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
  'errata': [
    'RHEA-2010:9999'
  ],
  'parameters': {
    'attr1': 'val1',
    'attr2': 'val2'
  }
}
"
    end

    it "should import template content" do
      @import_tpl = SystemTemplate.new(:environment => @organization.locker)

      @import_tpl.should_receive(:add_product).once.with('prod_a1').and_return nil
      @import_tpl.should_receive(:add_product).once.with('prod_a2').and_return nil
      @import_tpl.should_receive(:add_package).once.with('walrus').and_return nil
      @import_tpl.should_receive(:add_erratum).once.with('RHEA-2010:9999').and_return nil


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
      @export_tpl.stub(:errata).and_return [mock({:erratum_id => 'xxx'})]
      @export_tpl.stub(:parameters_json).and_return "{}"

      str = @export_tpl.string_export
      json = ActiveSupport::JSON.decode(str)
      json['products'].size.should == 2
      json['packages'].size.should == 1
      json['errata'].size.should == 1
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

      @err1 = SystemTemplateErratum.new(:erratum_id => "err1")
      @err1.stub(:to_erratum).and_return {}
      @err1.stub(:valid?).and_return true

      @tpl1.products << @prod1
      @tpl1.packages << @pack1
      @tpl1.errata << @err1
      @tpl1.save!

      id = @tpl1.id
      @tpl1.destroy

      SystemTemplateErratum.find_by_system_template_id(id).should == nil
      SystemTemplatePackage.find_by_system_template_id(id).should == nil
    end

  end

end
