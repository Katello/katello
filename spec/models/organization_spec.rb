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
    @organization = Organization.new(:name => 'test_org_name', :label=>'test_org_label')
    ForemanTasks.trigger(::Actions::Katello::Organization::Create, @organization)
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
        Organization.create!(:name => @organization.name + "_changed", :label => @organization.label)
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
      @organization = Organization.update(@organization.id, {:label => new_label})
      @organization.label.must_equal(new_label)
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
        @organization.update_attributes!({:name => @organization2.name})
      }.must_raise(ActiveRecord::RecordInvalid)
    end
    it "label update should fail when already taken for different org" do
      lambda{
        @organization.update_attributes!({:label => @organization2.label})
      }.must_raise(ActiveRecord::RecordInvalid)
    end
  end

  describe "update existing org name and create a new org using the original org name" do
    it "allows user to perform scenario" do
      original_org_name = "original org name"
      new_org_name = "new org name"

      @organization1 = Organization.create!(:name => original_org_name)
      assert_equal @organization1.name, original_org_name

      @organization1.name = new_org_name
      @organization1.save!
      assert_equal @organization1.name, new_org_name

      @organization2 = Organization.create!(:name => original_org_name)
      assert_equal @organization2.name, original_org_name
      refute_equal @organization1.label, @organization2.label
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
