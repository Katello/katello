require 'models/model_spec_helper'
module OrganizationHelperMethods
  include OrchestrationHelper

  def new_test_org user=nil
    disable_org_orchestration
    suffix = Organization.count + 1
    @organization = Organization.create!(:name => "test_organization#{suffix}", :cp_key => "test_organization#{suffix}")

    session[:current_organization_id] = @organization.id if defined? session
    return @organization
  end

  def new_test_org_model user=nil
    disable_org_orchestration
    suffix = Organization.count + 1
    @organization = Organization.create!(:name => "test_organization#{suffix}", :cp_key => "test_organization#{suffix}")
    return @organization
  end

  def current_organization=(org)
    controller.stub!(:current_organization).and_return(org)
  end

end
