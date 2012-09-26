# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'rubygems'
require 'test/integration/pulp/vcr_pulp_setup'


module ConsumerHelper

  @consumer_resource = Resources::Pulp::Consumer
  @consumer_id = "integration_test_consumer"

  def self.consumer_id
    @consumer_id
  end

  def self.create_consumer(package_profile=false)
    consumer = {}
    destroy_consumer
    VCR.use_cassette('pulp_consumer_helper') do
      consumer = @consumer_resource.create("", @consumer_id)

      if package_profile
        @consumer_resource.upload_package_profile(@consumer_id, [{"name" => "elephant", "version" => "0.2", "release" => "0.7", 
                                                        "epoch" => 0, "arch" => "noarch"}])
      end
    end
    return consumer
  rescue Exception => e
    p "TestPulpConsumer: Consumer #{@consumer_id} already existed."
  end

  def self.destroy_consumer
    VCR.use_cassette('pulp_consumer_helper') do
      @consumer_resource.destroy(@consumer_id)
    end
  rescue Exception => e
    p "TestPulpConsumer: No consumer #{@consumer_id} to delete."
  end

end
