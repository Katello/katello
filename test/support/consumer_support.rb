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

require 'test_helper'


module ConsumerSupport

  @consumer = nil

  def self.consumer_id
    @consumer.id
  end

  def self.consumer
    @consumer
  end

  def self.create_consumer(consumer_id)
    @consumer = System.find(consumer_id)

    VCR.use_cassette('support/consumer') do
      @consumer.set_pulp_consumer
    end
  ensure
    return @consumer
  end

  def self.destroy_consumer(id=@consumer_id)
    VCR.use_cassette('support/consumer') do
      @consumer.del_pulp_consumer if @consumer
    end
  rescue RestClient::ResourceNotFound => e
    #ignore if not found
  end

end
