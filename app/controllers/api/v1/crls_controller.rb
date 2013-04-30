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

class Api::V1::CrlsController < Api::V1::ApiController

  before_filter :authorize

  def rules
    superadmin_test = lambda { current_user.has_superadmin_role? }
    { :index => superadmin_test }
  end

  api :GET, "/crls", "Regenerate X.509 CRL immediately and return them"
  def index
    render :text => ::Resources::Candlepin::Proxy.get('/crl')
  end

end
