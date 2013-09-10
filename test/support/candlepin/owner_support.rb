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

module CandlepinOwnerSupport

  @organization = nil

  def self.organization_id
    @organization.id
  end

  def self.organization
    @organization
  end

  def self.create_organization(name, label)
    @organization = Organization.new
    @organization.name = name
    @organization.label = label
    @organization.description = 'New Organization'

    VCR.use_cassette('support/candlepin/organization', :match_requests_on => [:path, :params, :method, :body_json]) do
      @organization.set_owner
    end
  rescue => e
    puts e
  ensure
    return @organization
  end

  def self.destroy_organization(id=@organization_id, cassette='support/candlepin/organization')
    VCR.use_cassette(cassette, :match_requests_on => [:path, :params, :method, :body_json]) do
      @organization.del_owner
    end
  rescue RestClient::ResourceNotFound => e
    puts e
  end

end
