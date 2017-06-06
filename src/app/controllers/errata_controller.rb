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

class ErrataController < ApplicationController


  before_filter :lookup_errata
  before_filter :authorize

  def rules
    view = lambda{
      !Repository.readable_in_org(current_organization).where(
          :pulp_id=>@errata.repoids).empty?
    }
    {
        :show => view,
        :packages => view,
        :short_details => view
    }
  end

  def show
    render :partial=>"show"
  end

  def packages
    render :partial=>"packages"
  end

  def short_details
    render :partial=>"short_details"
  end

  private


  def lookup_errata
    @errata = Errata.find(params[:id])
  end

end
