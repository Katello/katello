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

Foreman::Application.routes.draw do
  match "/api/v2/organizations/*all", to: proc { [404, {}, ['']] }
  match "/api/v1/organizations/:id", via: :delete, to: proc { [404, {}, ['']] }

  resources :operatingsystems, :only => [] do
    get 'available_kickstart_repo', :on => :member
  end
end
