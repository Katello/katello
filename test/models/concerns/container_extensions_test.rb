# encoding: UTF-8
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

require 'katello_test_helper'

module Katello
  class ContainerExtensionsTest < ActiveSupport::TestCase
    def setup
      @container = FactoryGirl.create(:container)
    end

    def test_container_repo_url
      counter = OpenStruct.new(:count => 1)
      hostname = "www.redhat-registry.com"
      capsule = mock
      capsule.expects(:url => "http://" + hostname + ":8000")
      @container.stubs(:capsule).returns(capsule)
      Repository.expects(:where).with(:pulp_id => @container.repository_name).returns(counter)
      url = @container.repository_pull_url
      assert_equal "#{hostname}:5000/#{@container.repository_name}:#{@container.tag}", url
    end
  end
end
