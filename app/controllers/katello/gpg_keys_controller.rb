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
class GpgKeysController < Katello::ApplicationController
  before_filter :require_user
  before_filter :authorize

  respond_to :html, :js

  def section_id
    'contents'
  end

  def rules
    index_test = lambda{current_organization && GpgKey.any_readable?(current_organization)}
    {
      :index => index_test,
      :all => index_test,
    }
  end

  def index
    render 'bastion/layouts/application', :layout => false
  end

  def all
    redirect_to action: 'index', anchor: '/gpg_keys'
  end

end
end
