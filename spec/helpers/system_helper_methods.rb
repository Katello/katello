include OrganizationHelperMethods

module SystemHelperMethods
  def setup_system_creation
    Candlepin::Consumer.stub(:create).and_return({:owner=> { :key=> 'test_organization'}})
    Candlepin::Consumer.stub(:update).and_return({})
    Candlepin::Consumer.stub(:entitlements).and_return({})
    Candlepin::Consumer.stub(:available_pools).and_return([])
    new_test_org
  end

end