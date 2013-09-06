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

class Api::V1::ApiController < Api::ApiController

  include Api::Version1
  include Api::V1::ErrorHandling

  # support for session (thread-local) variables must be the last filter in this class
  include Util::ThreadSession::Controller
  include AuthorizationRules

  resource_description do
    api_version 'v1'
    api_version 'v2'
  end

  # remove unwanted parameters 'action' and 'controller' from params list and return it
  # and convert true/false strings to boolean types
  # note: you can use expected_params = params.slice('name') instead
  def query_params
    return @query_params if @query_params

    @query_params = params.clone
    @query_params.delete('controller')
    @query_params.delete('action')

    @query_params.each_pair do |k, v|

      if v.is_a?(String)
        if v.downcase == 'true'
          @query_params[k] = true
        elsif v.downcase == 'false'
          @query_params[k] = false
        end
      end
    end

    return @query_params
  end

  protected

  def find_organization
    @organization = find_optional_organization
    raise HttpErrors::NotFound, _("One of parameters [%s] required but not specified.") %
        organization_id_keys.join(", ") if @organization.nil?
    @organization
  end

  def find_optional_organization
    org_id = organization_id
    return if org_id.nil?

    @organization = get_organization(org_id)
    raise HttpErrors::NotFound, _("Couldn't find organization '%s'") % org_id if @organization.nil?
    @organization
  end

  def organization_id_keys
    return [:organization_id]
  end

  private

  def get_organization(org_id)
    # name/label is always unique
    return Organization.without_deleting.having_name_or_label(org_id).first
  end

  def organization_id
    key = organization_id_keys.find { |k| !params[k].nil? }
    return params[key]
  end

  def find_content_view_definition
    cvd_id      = params[:content_view_definition_id]
    @definition = ContentViewDefinition.find_by_id(cvd_id)
    if @definition.nil?
      raise HttpErrors::NotFound, _("Couildn't find content view with id '%s'") % cvd_id
    end
  end

  def find_content_filter_by_name
    filter_id = params[:filter_id]
    @filter   = Filter.where(:name => filter_id, :content_view_definition_id => @definition).first
    raise HttpErrors::NotFound, _("Couldn't find filter '%s'") % params[:id] if @filter.nil?
    @filter
  end

  def find_optional_environment
    @environment = KTEnvironment.find_by_id(params[:environment_id]) if params[:environment_id]
  end

  # Get the :label value from the params hash if it exists
  # otherwise use the :name value and convert to ASCII
  def labelize_params(params)
    return params[:label] unless params.try(:[], :label).nil?
    return Util::Model.labelize(params[:name]) unless params.try(:[], :name).nil?
  end

  protected

  def respond_for_index(options = {})
    collection = options[:collection] || get_resource_collection
    status     = options[:status] || :ok
    format     = options[:format] || :json

    render format => collection, :status => status
  end

  def respond_for_show(options = {})
    resource = options[:resource] || get_resource
    status   = options[:status] || :ok
    format   = options[:format] || :json

    render format => resource, :status => status
  end

  def respond_for_create(options = {})
    respond_for_show(options)
  end

  def respond_for_update(options = {})
    respond_for_show(options)
  end

  def respond_for_destroy(options = {})
    respond_for_status(options)
  end

  def respond_for_status(options = {})
    message = options[:message] || nil
    status  = options[:status] || :ok
    format  = options[:format] || :text

    render format => message, :status => status
  end

  def respond_for_async(options = {})
    resource = options[:resource] || get_resource
    status   = options[:status] || :ok
    format   = options[:format] || :json

    render format => resource, :status => status
  end

end
