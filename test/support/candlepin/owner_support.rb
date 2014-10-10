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
module CandlepinOwnerSupport

  @organization = nil

  def self.organization_id
    @organization.id
  end

  class << self
    attr_reader :organization
  end

  def self.set_owner(org)
    # TODO: this tests should move to actions tests once we
    # have more actions in Dynflow. For now just peform the
    # things that system.set_pulp_consumer did before.

    User.current.remote_id =  User.current.login
    ForemanTasks.sync_task(::Actions::Candlepin::Owner::Create,
                           name: org.name, label: org.label)
  end

  def set_owner(org)
    self.class.set_owner(org)
  end

  def self.create_organization(name, label)
    @organization = Organization.new
    @organization.name = name
    @organization.label = label
    @organization.description = 'New Organization'
    Organization.stubs(:disable_auto_reindex!).returns

    VCR.use_cassette('support/candlepin/organization', :match_requests_on => [:path, :params, :method, :body_json]) do
      set_owner(@organization)
    end
    return @organization
  rescue => e
    puts e
    return @organization
  end

  def self.destroy_organization(id = @organization_id, cassette = 'support/candlepin/organization')
    VCR.use_cassette(cassette, :match_requests_on => [:path, :params, :method, :body_json]) do
      Resources::Candlepin::Owner.destroy(@organization.label)
    end
  rescue RestClient::ResourceNotFound => e
    puts e
  end

end
end
