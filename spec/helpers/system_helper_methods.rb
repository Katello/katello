#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  module SystemHelperMethods
    def setup_system_creation
      Resources::Candlepin::Consumer.stubs(:create).returns(:owner => { :key => 'test_organization'})
      Resources::Candlepin::Consumer.stubs(:update).returns({})
      Resources::Candlepin::Consumer.stubs(:entitlements).returns({})
      Resources::Candlepin::Consumer.stubs(:compliance).returns({:compliance => true, :partiallyCompliantProducts => [], :nonCompliantProducts => []}.with_indifferent_access)
      Resources::Candlepin::Consumer.stubs(:available_pools).returns([])
      Resources::Candlepin::Consumer.stubs(:create).returns(:uuid => uuid, :owner => {:key => uuid})
      Resources::Candlepin::Consumer.stubs(:update).returns(true)

      Katello.pulp_server.extensions.consumer.stubs(:create).returns(:id => uuid)
      Katello.pulp_server.extensions.consumer.stubs(:update).returns(true)

      setup_test_org
    end

    def create_system(attrs)
      unless attrs.with_indifferent_access[:uuid]
        attrs[:uuid] = uuid
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
      refresh_response ||= expected_response
      Katello.pulp_server.extensions.consumer.stubs(:install_content).returns(expected_response)
      Katello.pulp_server.resources.task.stubs(:poll).returns(refresh_response)
    end
  end
end
