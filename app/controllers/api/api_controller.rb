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

class Api::ApiController < ActionController::Base
  include ActionController::HttpAuthentication::Basic
  include Profiling
  include KTLocale

  respond_to :json
  before_filter :require_user
  before_filter :verify_ldap
  before_filter :add_candlepin_version_header


  # override warden current_user (returns nil because there is no user in that scope)
  def current_user
    # get the logged user from the correct scope
    user(:api) || user
  end

  protected

  def add_candlepin_version_header
    response.headers["X-CANDLEPIN-VERSION"] = "katello/#{Katello.config.katello_version}"
  end

  def verify_ldap
    if !request.authorization.blank?
      u = current_user
      u.verify_ldap_roles if (Katello.config.ldap_roles && u != nil)
    end
  end

  def require_user

    if !request.authorization && current_user
      return true
    else
      params[:auth_username], params[:auth_password] = user_name_and_password(request) if request.authorization
      authenticate! :scope => :api
      params.delete('auth_username')
      params.delete('auth_password')
    end

  rescue => e
    logger.error "failed to authenticate API request: " << pp_exception(e)
    head :status => HttpErrors::INTERNAL_ERROR and return false
  end

  def request_from_katello_cli?
    request.user_agent.to_s =~ /^katello-cli/
  end

  # For situations where rhsm/subscirption-manager expect a bit
  # different behaviour.
  def request_from_rhsm?
    # We should rather use "x-python-rhsm-version" that are sent in
    # headers from subcription-manager, but this was added quite
    # recently: https://bugzilla.redhat.com/show_bug.cgi?id=790481.
    # For compatibility reasons we use the checking for katello_cli
    # instead for now. Therefore this method should be used only
    # rarely in cases where the expected behaviour differs between
    # this two agents, without large impact on other possible clients.
    !request_from_katello_cli?
  end

  def process_action(method_name, *args)
    super(method_name, *args)
    Rails.logger.debug "With body: #{response.body}\n"
  end

  def split_order(order)
    if order
      order.split("|")
    else
      [:name_sort, "ASC"]
    end
  end

  def get_resource
    instance_variable_get :"@#{resource_name}" or raise 'no resource loaded'
  end

  def get_resource_collection
    instance_variable_get :"@#{resource_collection_name}" or raise 'no resource collection loaded'
  end

  def resource_collection_name
    controller_name
  end

  def resource_name
    controller_name.singularize
  end

  def respond(options={})
    method_name = ('respond_for_'+params[:action].to_s).to_sym
    raise "automatic response method '%s' not defined" % method_name unless respond_to?(method_name, true)
    return send(method_name, options)
  end
end
