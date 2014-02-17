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

module Katello
class SyncPlansController < Katello::ApplicationController

  before_filter :authorize

  def rules
    read_test = lambda{current_organization && Provider.any_readable?(current_organization)}
    {
      :index => read_test,
      :all => read_test
    }
  end

  def index
    render 'bastion/layouts/application', :layout => false
  end

  def all
    redirect_to action: 'index', :anchor => '/sync-plans'
  end

  protected

  def controller_display_name
    return 'sync_plan'
  end

end
end
