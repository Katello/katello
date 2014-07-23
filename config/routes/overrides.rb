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
  match "/api/v1/organizations/:id", via: :delete, to: proc { [404, {}, ['']] }

  namespace :api, :defaults => {:format => 'json'} do
    scope "(:apiv)", :module => :v2, :defaults => {:apiv => 'v2'}, :apiv => /v1|v2/, :constraints => ApiConstraints.new(:version => 2) do
      resources :organizations, :except => [:new, :edit] do
        member do
          get :manifest_history
          post :repo_discover
          post :cancel_repo_discover
          post :autoattach_subscriptions
          get :download_debug_certificate
          get :redhat_provider
        end
      end
    end
  end
end
