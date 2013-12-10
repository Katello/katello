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
class Api::ApiController < ::Api::BaseController
  include Profiling
  include KTLocale

  respond_to :json
  before_filter :require_user
  before_filter :verify_ldap
  before_filter :add_candlepin_version_header

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

  def add_candlepin_version_header
    response.headers["X-CANDLEPIN-VERSION"] = "katello/#{Katello.config.katello_version}"
  end

  def verify_ldap
    if !request.authorization.blank?
      u = current_user
      u.verify_ldap_roles if (Katello.config.ldap_roles && !u.nil?)
    end
  end

  def require_user
    if authenticate && session[:user]
      User.current = User.find(session[:user])
    else
      # If the request is from rhsm, it may include a client cert; therefore, use it
      ssl_client_cert = client_cert_from_request
      unless ssl_client_cert.blank?
        consumer_cert = OpenSSL::X509::Certificate.new(ssl_client_cert)
        uuid = uuid(consumer_cert)
        User.current = CpConsumerUser.new(:uuid => uuid, :login => uuid, :remote_id => uuid)
      end
    end
  rescue => e
    logger.error "failed to authenticate API request: " << pp_exception(e)
    head :status => HttpErrors::INTERNAL_ERROR
    return false
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

  def client_cert_from_request
    cert = request.env['SSL_CLIENT_CERT'] || request.env['HTTP_SSL_CLIENT_CERT']
    return nil if cert.blank? || cert == "(null)"
    # apache does not preserve new lines in cert file - work-around:
    if cert.include?("-----BEGIN CERTIFICATE----- ")
      cert = cert.to_s.gsub("-----BEGIN CERTIFICATE----- ", "").gsub(" -----END CERTIFICATE-----", "")
      cert.gsub!(" ", "\n")
      cert = "-----BEGIN CERTIFICATE-----\n#{cert}-----END CERTIFICATE-----\n"
    end
    return cert
  end

  def uuid(cert)
    drop_cn_prefix_from_subject(cert.subject.to_s)
  end

  def drop_cn_prefix_from_subject(subject_string)
    subject_string.sub(/\/CN=/i, '')
  end

  def trigger(action, *args)
    ::ForemanTasks.trigger(action, *args)
  end

  # trigger dynflow action and return the dynflow task object
  def async_task(action, *args)
    execution_plan_id = trigger(action, *args).id
    return ::ForemanTasks::Task::DynflowTask.find_by_external_id!(execution_plan_id)
  end

end
end
