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

class Api::V2::UsersController < Api::V1::UsersController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def_param_group :user do
    param :user, Hash, :required => true, :action_aware => true do
      param :email, String, :required => true, :action_aware => true
      param :password, String, :required => true, :action_aware => true
      param :default_environment_id, Integer, :action_aware => true
      param :disabled, :bool, :action_aware => true
    end
  end

  def param_rules
    { :create => { :user => [:username, :password, :email, :disabled, :default_environment_id, :default_locale] },
      :update => { :user => [:password, :email, :disabled, :default_environment_id, :default_locale] }
    }
  end

  api :POST, "/users", "Create an user"
  param_group :user
  param :user, Hash, :required => true do
    param :username, String, :required => true
  end
  def create
    user_attrs = params[:user]

    @user = User.create!(user_attrs)

    if user_attrs[:default_environment_id]
      @user.default_environment = KTEnvironment.find(user_attrs[:default_environment_id])
      @user.save!
    end

    if !user_attrs[:default_locale].blank?
      #TODO: this should be placed in model validations
      if Katello.config.available_locales.include? user_attrs[:default_locale]
        @user.default_locale = user_attrs[:default_locale]
        @user.save!
      end
    end
    respond
  end

  api :PUT, "/users/:id", "Update an user"
  param_group :user
  def update
    super
  end

  # rhsm
  def list_owners
    respond_for_index :collection => @user.allowed_organizations
  end

end
