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

class Api::Foreman::SimpleCrudController < Api::ApiController

  def rules
    superadmin_test = lambda { current_user.has_superadmin_role? }
    actions         = [:index, :show, :create, :update, :destroy]

    actions.inject({ }) { |hash, action| hash.update action => superadmin_test }
  end

  def index(request_options = nil)
    render :json => foreman_model.all(request_options).as_json(json_options(:index))
  end

  def show
    render :json => foreman_model.find!(params[:id]).as_json(json_options(:show))
  end

  def create
    resource = foreman_model.new(params[foreman_model.resource_name])
    if resource.save!
      render :json => resource.as_json(json_options(:create))
    end
  end

  def update
    resource = foreman_model.find!(params[:id])
    if resource.update_attributes!(params[foreman_model.resource_name])
      render :json => resource.as_json(json_options(:update))
    end
  end

  def destroy
    resource = foreman_model.find!(params[:id])
    if resource.destroy!
      render :nothing => true
    end
  end

  def json_options(action)
    method_name = (action.to_s+'_json_options').to_sym

    return send method_name if respond_to? method_name
    return send :common_json_options if respond_to? :common_json_options
    return nil
  end

  singleton_class.send :attr_reader, :foreman_model

  # @api private
  attr_writer :foreman_model

  def foreman_model
    @foreman_model or self.class.foreman_model or
        raise ArgumentError,
              "Please specify foreman model class using 'self.foreman_model = ClassName' in #{self.class} definition."
  end

  private
  singleton_class.send :attr_writer, :foreman_model
end
