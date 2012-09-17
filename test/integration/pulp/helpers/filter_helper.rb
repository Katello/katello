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


module FilterHelper

  @filter_resource = Resources::Pulp::Filter
  @filter_id = "integration_test_filter"

  def self.filter_id
    @filter_id
  end

  def self.create_filter
    filter = {}
    destroy_filter
    VCR.use_cassette('pulp_filter_helper') do
      filter = @filter_resource.create(:id => @filter_id, :type => "blacklist", :package_list => ['cheetah'])
    end
    return filter
  rescue Exception => e
    p "TestPulpFilter: Filter #{@filter_id} already existed."
  end

  def self.destroy_filter
    VCR.use_cassette('pulp_filter_helper') do
      @filter_resource.destroy(@filter_id)
    end
  rescue Exception => e
    p "TestPulpFilter: No filter #{@filter_id} to delete."
  end

end
