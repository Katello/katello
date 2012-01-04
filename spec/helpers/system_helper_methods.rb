include OrganizationHelperMethods

module SystemHelperMethods
  def setup_system_creation
    Candlepin::Consumer.stub(:create).and_return({:owner=> { :key=> 'test_organization'}})
    Candlepin::Consumer.stub(:update).and_return({})
    Candlepin::Consumer.stub(:entitlements).and_return({})
    Candlepin::Consumer.stub(:compliance).and_return({:compliance=>true, :partiallyCompliantProducts=>[], :nonCompliantProducts=>[]}.with_indifferent_access)
    Candlepin::Consumer.stub(:available_pools).and_return([])
      Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Candlepin::Consumer.stub!(:update).and_return(true)

      Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Pulp::Consumer.stub!(:update).and_return(true)
    new_test_org
  end

end