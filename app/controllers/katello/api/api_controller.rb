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

module Katello
class Api::ApiController < ::Api::BaseController
  include Profiling
  include KTLocale
  include ForemanTasks::Triggers

  respond_to :json
  before_filter :verify_ldap
  before_filter :turn_off_strong_params

  # override warden current_user (returns nil because there is no user in that scope)
  def current_user
    # get the logged user from the correct scope
    User.current
  end

  def load_search_service(service = nil)
    if service.nil?
      @search_service ||= Glue::ElasticSearch::Items.new
    else
      @search_service ||= service
    end
  end

  protected

  # Override Foreman authorized method to call the Katello authorize check
  def authorized
    if converted_controllers.include?(request.params['controller'])
      super
    else
      authorize_katello
    end
  end

  def converted_controllers
    [
      'katello/api/v2/activation_keys',
      'katello/api/v2/content_views',
      'katello/api/v2/content_view_filters',
      'katello/api/v2/content_view_filter_rules',
      'katello/api/v2/content_view_puppet_modules',
      'katello/api/v2/content_view_versions',
      'katello/api/v2/gpg_keys',
      'katello/api/v2/host_collections',
      'katello/api/v2/sync_plans',
      'katello/api/v2/products',
      'katello/api/v2/repositories',
      'katello/api/v2/products_bulk_actions',
      'katello/api/v2/repositories_bulk_actions',
      'katello/api/v2/content_uploads',
      'katello/api/v2/organizations',
      'katello/api/v2/subscriptions',
      'katello/api/v2/sync',
      'katello/api/v2/environments',
      'katello/api/v2/systems',
      'katello/api/v2/system_packages',
      'katello/api/v2/system_errata',
      'katello/api/v2/systems_bulk_actions',
      'katello/api/v1/candlepin_proxies'
    ]
  end

  def verify_ldap
    if !request.authorization.blank?
      u = current_user
      u.verify_ldap_roles if (Katello.config.ldap_roles && !u.nil?)
    end
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
    resource = instance_variable_get(:"@#{resource_name}")
    fail 'no resource loaded' if resource.nil?
    resource
  end

  def get_resource_collection
    resource = instance_variable_get(:"@#{resource_collection_name}")
    fail 'no resource collection loaded' if resource.nil?
    resource
  end

  def resource_collection_name
    controller_name
  end

  def resource_name
    controller_name.singularize
  end

  def respond(options = {})
    method_name = ('respond_for_' + params[:action].to_s).to_sym
    fail "automatic response method '%s' not defined" % method_name unless respond_to?(method_name, true)
    return send(method_name, options)
  end

  def format_bulk_action_messages(args = {})
    models     = args.fetch(:models)
    authorized = args.fetch(:authorized)
    messages   = {:success => [], :error => []}

    unauthorized = models - authorized

    messages[:success] << args.fetch(:success) % authorized.length if authorized.present?
    messages[:error] << args.fetch(:error) % unauthorized if unauthorized.present?

    messages
  end

end
end
