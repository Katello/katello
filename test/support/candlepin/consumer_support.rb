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

require 'minitest_helper'


module CandlepinConsumerSupport

  @system = nil

  def self.system_id
    @system.id
  end

  def self.system
    @system
  end

  def self.create_system(name, env, cv)
    @system = System.new
    @system.cp_type = 'system'
    @system.name = name
    @system.description = 'New System'
    @system.environment = env
    @system.content_view = cv
    @system.facts = {}
    @system.arch = 'x86_64'
    @system.sockets = 2
    @system.memory = 256
    @system.guest = false

    VCR.use_cassette('support/candlepin/system', :match_requests_on => [:path, :params, :method, :body_json]) do
      @system.set_candlepin_consumer
    end
  rescue => e
    puts e
  ensure
    return @system
  end

  def self.destroy_system(id=@system_id, cassette='support/candlepin/system')
    VCR.use_cassette(cassette, :match_requests_on => [:path, :params, :method, :body_json]) do
      @system.del_candlepin_consumer
    end
  rescue RestClient::ResourceNotFound => e
    puts e
  end

  @distributor = nil

  def self.distributor_id
    @distributor.id
  end

  def self.distributor
    @distributor
  end

  def self.create_distributor(name, env, cv)
    @distributor = Distributor.new
    @distributor.cp_type = 'candlepin'
    @distributor.name = name
    @distributor.description = 'New Distributor'
    @distributor.environment = env
    @distributor.content_view = cv
    @distributor.facts = {}

    VCR.use_cassette('support/candlepin/distributor', :match_requests_on => [:path, :params, :method, :body_json]) do
      @distributor.set_candlepin_consumer
    end
  rescue => e
    puts e
  ensure
    return @distributor
  end

  def self.destroy_distributor(id=@distributor_id, cassette='support/candlepin/distributor')
    VCR.use_cassette(cassette, :match_requests_on => [:path, :params, :method, :body_json]) do
      @distributor.del_candlepin_consumer
    end
  rescue RestClient::ResourceNotFound => e
    puts e
  end

end
