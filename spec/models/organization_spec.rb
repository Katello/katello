require 'katello_test_helper'

module Katello
  describe Organization do
    include OrganizationHelperMethods
    include Dynflow::Testing

    before(:each) do
      stub_ping
      User.current = User.find(users(:admin).id)
      disable_foreman_tasks_hooks_execution(Organization)
      disable_env_orchestration
      Organization.any_instance.stubs(:ensure_not_in_transaction!)
      @organization = Organization.new(:name => 'test_org_name', :label => 'test_org_label')
      ::Actions::Katello::Organization::Create.any_instance.stubs(:action_subject)
      create_and_plan_action(::Actions::Katello::Organization::Create, @organization)
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
    end

    describe "create an organization" do
      specify { @organization.name.must_equal('test_org_name') }
      specify { @organization.label.must_equal('test_org_label') }
      specify { @organization.library.wont_be_nil }
      specify { @organization.redhat_provider.wont_be_nil }
      specify { @organization.kt_environments.size.must_equal(1) }
      specify { Organization.where(:name => @organization.name).size.must_equal(1) }
      specify { Organization.where(:name => @organization.name).first.must_equal(@organization) }

      it "should complain on duplicate name" do
        update = lambda do
          Organization.create!(:name => @organization.name, :label => @organization.name + "_changed")
        end
        update.must_raise(ActiveRecord::RecordInvalid)
      end
      it "should complain on duplicate label" do
        update = lambda do
          Organization.create!(:name => @organization.name + "_changed", :label => @organization.label)
        end
        update.must_raise(ActiveRecord::RecordInvalid)
      end
      it "should complain if the label is invalid" do
        update = lambda do
          Organization.create!(:label => "ACME\n<badlabel>", :name => "ACMECorp")
        end
        update.must_raise(ActiveRecord::RecordInvalid)
      end
    end

    describe "update an organization" do
      before(:each) do
        @organization2 = Organization.create!(:name => 'test_org_name2', :label => 'test_org_label2')
      end
      it "can update name" do
        new_name = @organization.name + "_changed"
        @organization = Organization.update(@organization.id, :name => new_name)
        @organization.name.must_equal(new_name)
      end
      it "can update label" do
        new_label = @organization.label + "_changed"
        @organization = Organization.update(@organization.id, :label => new_label)
        @organization.label.must_equal(new_label)
      end
      it "name update is ok for overlapping label from the same org" do
        @organization = Organization.update(@organization.id, :name => @organization.label)
        @organization.name.must_equal(@organization.label)
      end
      it "label update is ok for overlapping name from the same org" do
        @organization = Organization.update(@organization.id, :label => @organization.name)
        @organization.label.must_equal(@organization.name)
      end
      it "name update should fail when already taken for different org" do
        update = lambda do
          @organization.update_attributes!(:name => @organization2.name)
        end
        update.must_raise(ActiveRecord::RecordInvalid)
      end
      it "label update should fail when already taken for different org" do
        update = lambda do
          @organization.update_attributes!(:label => @organization2.label)
        end

        update.must_raise(ActiveRecord::RecordInvalid)
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
        @organization.expects(:imports).returns([{'foo' => 'bar' }, {'foo' => 'bar'}])
        assert @organization.manifest_history[0].foo == 'bar'
      end
    end
  end
end
