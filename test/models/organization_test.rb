# encoding: utf-8

require 'katello_test_helper'

module Katello
  class OrganizationTestDelete < ActiveSupport::TestCase
    def test_org_being_deleted
      Organization.any_instance.stubs(:being_deleted?).returns(true)
      User.current = User.find(users(:admin).id)
      org = get_organization(:organization2)
      org.content_view_environments.first.destroy!
      org.reload.library.destroy!
      org.reload.kt_environments.destroy_all
      id = org.id
      org.destroy!
      assert_nil Organization.find_by_id(id)
    end

    def test_org_katello_params
      org = Organization.new(:name => 'My Org', :label => 'my_org')
      org.instance_variable_set('@service_level', 'foo')
      org.stubs(:service_level=)
      org.update_attributes(:service_level => 'bar')
      assert(org.valid?)
    end

    test_attributes :pid => '344573dd-5c46-4d8d-a3cf-e734a7a90ffa'
    def test_should_not_update_label
      org = Organization.new(:name => 'My Org', :label => 'my_org')
      org.save!
      org.label = 'my_org_label'
      refute_valid org
      assert org.errors.include?(:label)
      assert_equal 'cannot be changed.', org.errors[:label][0]
    end
  end
end
