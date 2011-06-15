module OrganizationHelperMethods
  def new_test_org user=nil
    Candlepin::Owner.stub!(:create_user).and_return(true)
    Candlepin::Owner.should_receive(:create).at_least(:once).and_return({})
    @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
  end

end
