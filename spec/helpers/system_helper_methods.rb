include OrganizationHelperMethods

module SystemHelperMethods
  def setup_system_creation
    new_test_org
    Candlepin::Consumer.should_receive(:create).at_least(:once).and_return({:owner=> { :key=> 'test_organization'}})
  end

end