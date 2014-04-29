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
describe Organization do
  include OrganizationHelperMethods

  before(:each) do
    disable_foreman_tasks_hooks_execution(Organization)
    disable_env_orchestration
    Organization.any_instance.stubs(:ensure_not_in_transaction!)
    @organization = Organization.create!(:name => 'test_org_name', :label=>'test_org_label')
  end

  describe "organization validation" do
    specify { Organization.new(:name => 'name', :label => 'org').must_be :valid? }
    specify { Organization.new(:name => 'name', :label => 'with_underscore').must_be :valid? }
    specify { Organization.new(:name => 'name', :label => 'With_Capital_letter').must_be :valid? }
    specify { Organization.new(:name => 'name', :label => 'with_number').must_be :valid? }
    specify { Organization.new(:name => 'name', :label => 'with\'space').wont_be :valid? }
    specify { Organization.new(:name => 'o', :label => 'o').must_be :valid? }
    # creates :label from name
    specify { Organization.new(:name => 'without label').must_be :valid? }
    specify { Organization.new(:label => 'without_name').wont_be :valid? }
    specify { Organization.new(:label => 'without_name').wont_be :valid? }
    specify do
      o = Organization.new(:name => "default_info_valid")
      o.default_info["system"] << "less than 256 characters"
      o.must_be :valid?
    end
    specify do
      o = Organization.new(:name => "default_info_invalid")
      o.default_info["system"] << ""
      o.wont_be :valid?
    end
    specify do
      o = Organization.new(:name => "default_info_invalid")
      o.default_info["system"] << ("a" * 300)
      o.wont_be :valid?
    end
  end

  describe "create an organization" do
    specify {@organization.name.must_equal('test_org_name')}
    specify {@organization.label.must_equal('test_org_label')}
    specify {@organization.library.wont_be_nil}
    specify {@organization.redhat_provider.wont_be_nil}
    specify {@organization.kt_environments.size.must_equal(1)}
    specify {Organization.where(:name => @organization.name).size.must_equal(1)}
    specify {Organization.where(:name => @organization.name).first.must_equal(@organization)}

    it "should complain on duplicate name" do
      lambda{
        Organization.create!(:name => @organization.name, :label => @organization.name + "_changed")
      }.must_raise(ActiveRecord::RecordInvalid)
    end
    it "should complain on duplicate label" do
      lambda{
        Organization.create!(:name => @organization.name + "_changed", :label =>@organization.name)
      }.must_raise(ActiveRecord::RecordInvalid)
    end
    it "should complain on duplicate name when label is taken" do
      lambda{
        Organization.create!(:name => @organization.label)
      }.must_raise(ActiveRecord::RecordInvalid)
    end
    it "should complain on duplicate label when name is taken" do
      lambda{
        Organization.create!(:label => @organization.name)
      }.must_raise(ActiveRecord::RecordInvalid)
    end
    it "should complain if the label is invalid" do
      lambda{
        Organization.create!(:label => "ACME\n<badlabel>", :name => "ACMECorp")
      }.must_raise(ActiveRecord::RecordInvalid)
    end
  end

  describe "update an organization" do
    before(:each) do
      @organization2 = Organization.create(:name => 'test_org_name2', :label=>'test_org_label2')
    end
    it "can update name" do
      new_name = @organization.name + "_changed"
      @organization = Organization.update(@organization.id, {:name => new_name})
      @organization.name.must_equal(new_name)
    end
    it "can update label" do
      new_label = @organization.label + "_changed"
      @organization = Organization.update(@organization.id, {:name => new_label})
      @organization.name.must_equal(new_label)
    end
    it "name update is ok for overlapping label from the same org" do
      @organization = Organization.update(@organization.id, {:name => @organization.label})
      @organization.name.must_equal(@organization.label)
    end
    it "label update is ok for overlapping name from the same org" do
      @organization = Organization.update(@organization.id, {:label => @organization.name})
      @organization.label.must_equal(@organization.name)
    end
    it "name update should fail when already taken for different org" do
      lambda{
        @organization.update_attributes!({:name => @organization2.label})
      }.must_raise(ActiveRecord::RecordInvalid)
    end
    it "label update should fail when already taken for different org" do
      lambda{
        @organization.update_attributes!({:label => @organization2.name})
      }.must_raise(ActiveRecord::RecordInvalid)
    end
  end

  describe "delete an organization" do
    before do
      Resources::Candlepin::Owner.expects(:destroy).at_least_once.returns({})
    end

    it "can delete the org" do
      id = @organization.id
      Organization.any_instance.stubs(:being_deleted?).returns(true)
      @organization.destroy

      @organization.must_be :destroyed?
      lambda{Organization.find(id)}.must_raise(ActiveRecord::RecordNotFound)
    end

    it "can delete the org and envs are deleted" do
      org_id = @organization.id

      env_name = "prod"
      @env = KTEnvironment.new(:name=>env_name, :label=> env_name, :library => false, :prior => @organization.library)
      @organization.kt_environments << @env
      @env.save!

      Organization.any_instance.stubs(:being_deleted?).returns(true)
      @organization.reload.destroy

      lambda{Organization.find(org_id)}.must_raise(ActiveRecord::RecordNotFound)
      KTEnvironment.where(:name => env_name).all.must_be_empty
    end

    it "can delete the org and env of a different org exist" do
      env_name = "prod"

      @org2 = Organization.create!(:name=>"foobar", :label=> "foobar")

      @env1 = KTEnvironment.new(:name=>env_name, :label=> env_name, :organization => @organization, :prior => @organization.library)
      @organization.kt_environments << @env1
      @env1.save!

      @env2 = KTEnvironment.new(:name=>env_name, :label=> env_name, :organization => @org2, :prior => @organization.library)
      @org2.kt_environments << @env2
      @env2.save!

      id1 = @organization.id
      Organization.any_instance.stubs(:being_deleted?).returns(true)
      @organization.reload.destroy
      lambda{Organization.find(id1)}.must_raise(ActiveRecord::RecordNotFound)

      KTEnvironment.where(:name => env_name).first.must_equal(@env2)
      KTEnvironment.where(:name => env_name).size.must_equal(1)
    end

    it "can delete an org where there is a full environment path" do
       dev = create_environment(:name=>"Dev-34343", :label=> "Dev", :organization => @organization, :prior => @organization.library)
       qa = create_environment(:name=>"QA", :label=> "QA", :organization => @organization, :prior => dev)
       prod =  create_environment(:name=>"prod", :label=> "prod", :organization => @organization, :prior => qa)
       Organization.any_instance.stubs(:being_deleted?).returns(true)

       @organization = @organization.reload
       @organization.destroy
       lambda{Organization.find(@organization.id)}.must_raise(ActiveRecord::RecordNotFound)
       KTEnvironment.where(:name =>'Dev-34343').size.must_equal(0)
    end
  end

  describe "it can retrieve manifest history" do
    test 'test manifest history should be successful' do 
      @organization = @organization.reload
      @organization.expects(:imports).returns([{'foo' => 'bar' },{'foo' => 'bar'}])
      assert @organization.manifest_history[0].foo == 'bar'
    end
  end
end
end
