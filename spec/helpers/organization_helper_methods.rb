module OrganizationHelperMethods
  def new_test_org user=nil
    Candlepin::Owner.stub!(:create_user).and_return(true)
    Candlepin::Owner.stub!(:create).and_return({})
    @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')

    session[:current_organization_id] = @organization.id
    return @organization
  end

  def current_organization=(org)
    controller.stub!(:current_organization).and_return(org)
  end

end
