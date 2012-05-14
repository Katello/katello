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

  def create_system attrs
    if attrs.with_indifferent_access[:uuid]
      required_uuid = attrs.with_indifferent_access[:uuid]
      Candlepin::Consumer.stub!(:create).and_return({:uuid => required_uuid, :owner => {:key => required_uuid}})
    end
    System.create!(attrs)
  end

  def pulp_task_without_error
    {
      :id => '123',
      :state => 'waiting',
      :start_time => Time.now,
      :finish_time => Time.now,
      :result => "hurray"
    }.with_indifferent_access
  end

  def updated_pulp_task
    {
      :id => '123',
      :state => 'finished',
      :start_time => Time.now,
      :finish_time => Time.now + 60,
      :result => "yippie"
    }.with_indifferent_access
  end

  def pulp_task_with_error
    {
      :id => '123',
      :state => 'error',
      :start_time => Time.now,
      :finish_time => Time.now,
      :exception => "exception",
      :traceback => "traceback"
    }.with_indifferent_access
  end


  def stub_consumer_packages_install(expected_response, refresh_response = nil)
    refresh_response ||= expected_response
    Pulp::Consumer.stub!(:install_packages).and_return(expected_response)
    Pulp::Task.stub!(:find).and_return([refresh_response])
  end

end