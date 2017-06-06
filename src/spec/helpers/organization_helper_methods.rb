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

require 'models/model_spec_helper'
module OrganizationHelperMethods
  include OrchestrationHelper

  def new_test_org user=nil
    disable_org_orchestration
    suffix = Organization.count + 1
    @organization = Organization.create!(:name=>"test_organization#{suffix}", :label=> "test_organization#{suffix}_label")
    session[:current_organization_id] = @organization.id if defined? session
    return @organization
  end

  def new_test_org_model user=nil
    disable_org_orchestration
    suffix = Organization.count + 1
    @organization = Organization.create!(:name=>"test_organization#{suffix}", :label=> "test_organization#{suffix}_label")
    return @organization
  end

  def current_organization=(org)
    controller.stub!(:current_organization).and_return(org)
  end

end
