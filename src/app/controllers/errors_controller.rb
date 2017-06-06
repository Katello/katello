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

class ErrorsController < ApplicationController
  skip_before_filter :require_user, :require_org
  skip_before_filter :authorize # ok - is used by warden

  # handles unknown routes from both / and /api namespaces
  def routing
    path = params['a']
    ex = HttpErrors::NotFound.new( _("Route does not exist:") + " #{path}" )

    if path.match('/api/')
      # custom message which will render in JSON
      logger.error ex.message
      respond_to do |format|
        format.json { render :json => {:displayMessage => ex.message, :errors => [ex.message]}, :status => 404}
        format.all { render :text => "#{ex.message}", :status => 404}
      end
    else
      render_404 ex
    end
  end
end
