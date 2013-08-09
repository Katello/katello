#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

include OrganizationHelperMethods

module SystemHelperMethods
  def setup_system_creation
    Resources::Candlepin::Consumer.stub(:create).and_return({:owner=> { :key=> 'test_organization'}})
    Resources::Candlepin::Consumer.stub(:update).and_return({})
    Resources::Candlepin::Consumer.stub(:entitlements).and_return({})
    Resources::Candlepin::Consumer.stub(:compliance).and_return({:compliance=>true, :partiallyCompliantProducts=>[], :nonCompliantProducts=>[]}.with_indifferent_access)
    Resources::Candlepin::Consumer.stub(:available_pools).and_return([])
    Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Resources::Candlepin::Consumer.stub!(:update).and_return(true)

    if Katello.config.katello?
      Katello.pulp_server.extensions.consumer.stub!(:create).and_return({ :id => uuid })
      Katello.pulp_server.extensions.consumer.stub!(:update).and_return(true)
    end
    new_test_org
  end

  def create_system attrs
    if attrs.with_indifferent_access[:uuid]
      required_uuid = attrs.with_indifferent_access[:uuid]
      Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => required_uuid, :owner => {:key => required_uuid}})
    end

    if attrs[:environment] && !attrs[:environment].library? && !attrs[:content_view]
      view = find_or_create_content_view(attrs[:environment])
      attrs[:content_view] = view
    end

    sys = System.create!(attrs)
    if block_given?
      yield sys
      sys.save!
    end
    sys
  end

  def pulp_task_without_error
    {
      :task_id => '123',
      :state => 'waiting',
      :start_time => Time.now,
      :finish_time => Time.now,
      :result => "hurray"
    }.with_indifferent_access
  end

  def updated_pulp_task
    {
      :task_id => '123',
      :state => 'finished',
      :start_time => Time.now,
      :finish_time => Time.now + 60,
      :result => "yippie"
    }.with_indifferent_access
  end

  def pulp_task_with_error
    {
      :task_id => '123',
      :state => 'error',
      :start_time => Time.now,
      :finish_time => Time.now,
      :exception => "exception",
      :traceback => "traceback"
    }.with_indifferent_access
  end


  def stub_consumer_packages_install(expected_response, refresh_response = nil)
    if Katello.config.katello?
      refresh_response ||= expected_response
      Katello.pulp_server.extensions.consumer.stub!(:install_content).and_return(expected_response)
      Katello.pulp_server.resources.task.stub!(:poll).and_return(refresh_response)
    end
  end

end
