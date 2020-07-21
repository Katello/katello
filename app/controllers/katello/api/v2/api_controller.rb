module Katello
  class Api::V2::ApiController < ::Api::V2::BaseController
    include Concerns::Api::ApiController
    include Api::Version2
    include Api::V2::Rendering
    include Api::V2::ErrorHandling
    include ::Foreman::Controller::CsvResponder
    include Concerns::Api::V2::AssociationsPermissionCheck

    # support for session (thread-local) variables must be the last filter in this class
    include Foreman::ThreadSession::Cleaner

    skip_before_action :setup_has_many_params # TODO: get this working #8862
    # avoid a duplicate log message from Foreman's API::BaseController with private keys not filtered out
    skip_after_action :log_response_body

    resource_description do
      api_version 'v2'
      api_base_url "/katello/api"
    end

    def_param_group :search do
      param :search, String, :desc => N_("Search string")
      param :page, :number, :desc => N_("Page number, starting at 1")
      param :per_page, :number, :desc => N_("Number of results per page to return")
      param :order, String, :desc => N_("Sort field and order, eg. 'id DESC'")
      param :full_result, :bool, :desc => N_("Whether or not to show all results")
      param :sort_by, String, :desc => N_("Field to sort the results on")
      param :sort_order, String, :desc => N_("How to order the sorted results (e.g. ASC for ascending)")
    end

    param :object_root, String, :desc => N_("root-node of single-resource responses (optional)")
    param :root_name, String, :desc => N_("root-node of collection contained in responses (default: 'results')")

    def resource_class
      @resource_class ||= resource_name.classify.constantize
    rescue NameError
      @resource_class ||= "Katello::#{resource_name.classify}".constantize
    end

    def deprecate_katello_agent
      ::Foreman::Deprecation.api_deprecation_warning("Remote actions using katello-agent are deprecated and will be removed in Katello 4.0.  " \
                                                         "You may consider switching to Remote Execution.")
    end

    def full_result_response(collection)
      { :results => collection,
        :total => collection.count,
        :page => 1,
        :per_page => collection.count,
        :subtotal => collection.count }
    end

    def empty_search_query?
      search_options[0].blank?
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    def scoped_search(query, default_sort_by, default_sort_order, options = {})
      params[:sort_by] ||= default_sort_by
      params[:sort_order] ||= default_sort_order

      resource = options[:resource_class] || resource_class
      includes = options.fetch(:includes, [])
      group = options.fetch(:group, nil)
      deterministic_order = options.fetch(:deterministic_order, "#{query.table_name}.id DESC")
      params[:full_result] = true if options[:csv]
      blank_query = resource.none

      if params[:order]
        (params[:sort_by], params[:sort_order]) = params[:order].split(' ')
      else
        params[:order] = "#{params[:sort_by]} #{params[:sort_order]}"
      end

      total = scoped_search_total(query, group)

      query = query.select(:id) if query.respond_to?(:select)
      query = resource.search_for(*search_options).where("#{resource.table_name}.id" => query)

      query = self.final_custom_index_relation(query) if self.respond_to?(:final_custom_index_relation)

      query = query.select(group).group(group) if group
      sub_total = total.zero? ? 0 : scoped_search_total(query, group)

      if options[:custom_sort]
        query = options[:custom_sort].call(query)
      end
      query = query.order(deterministic_order) unless group #secondary order to ensure sort is deterministic
      query = query.includes(includes) if includes.length > 0

      if ::Foreman::Cast.to_bool(params[:full_result])
        params[:per_page] = total
      else
        query = query.paginate(paginate_options)
      end
      page = params[:page] || 1
      per_page = params[:per_page] || Setting[:entries_per_page]
      query = (total.zero? || sub_total.zero?) ? blank_query : query

      options[:csv] ? query : scoped_search_results(query, sub_total, total, page, per_page)
    rescue ScopedSearch::QueryNotSupported, ActiveRecord::StatementInvalid => error
      message = error.message
      if error.class == ActiveRecord::StatementInvalid
        Rails.logger.error("Invalid search: #{error.message}")
        message = _('Your search query was invalid. Please revise it and try again. The full error has been sent to the application logs.')
      end

      scoped_search_results(blank_query, 0, 0, page, per_page, message)
    end

    protected

    def scoped_search_total(query, group)
      if group
        query.select(group).group(group).length
      else
        query.count
      end
    end

    def scoped_search_results(query, sub_total, total, page, per_page, error = nil)
      {
        :results => query,
        :subtotal => sub_total,
        :total => total,
        :page => page,
        :per_page => per_page,
        :error => error
      }
    end

    def labelize_params(param_hash)
      return param_hash[:label] unless param_hash.try(:[], :label).nil?
      return Util::Model.labelize(param_hash[:name]) unless param_hash.try(:[], :name).nil?
    end

    def find_organization
      @organization = Organization.current || find_optional_organization
      if @organization.nil?
        fail HttpErrors::NotFound, _("One of parameters [ %s ] required but not specified.") %
            organization_id_keys.join(", ")
      end
      @organization
    end

    def sort_params
      options = {}
      options[:sort_by] = params[:sort_by] if params[:sort_by]
      options[:sort_order] = params[:sort_order] if params[:sort_order]
      options
    end

    def find_optional_organization
      org_id = organization_id
      return if org_id.nil?

      @organization = get_organization(org_id)
      fail HttpErrors::NotFound, _("Couldn't find organization '%s'") % org_id if @organization.nil?
      @organization
    end

    def organization_id
      key = organization_id_keys.find { |k| !params[k].nil? }
      return params[key]
    end

    def organization_id_keys
      return [:organization_id]
    end

    def get_organization(org_id)
      return Organization.find_by(:id => org_id)
    end

    def csv_response(resources, columns = csv_columns, header = nil, filename = nil)
      if filename || Organization.current.blank?
        super
      else
        filename = "#{Organization.current.label}-#{controller_name}-#{Date.today}.csv"
        super(resources, columns, header, filename)
      end
    end

    def find_default_organization_and_or_environment
      return if (params.keys & %w(organization_id owner environment_id host_collection_id)).any?

      if current_user.default_organization.present?
        @organization = current_user.default_organization
        @environment = @organization.library
      else
        fail HttpErrors::NotFound, _("You have not set a default organization on the user %s.") % current_user.login
      end
    end

    def respond_for_show(options = {})
      check_resource_organization(options[:resource], params[:organization_id])
      super
    end

    def check_resource_organization(resource, organization_id)
      return unless resource.try(:organization_id) && organization_id
      if resource.organization_id != organization_id.to_i
        fail HttpErrors::BadRequest, _("The requested resource does not belong to the specified Organization")
      end
    end

    def find_host_with_subscriptions(id, permission)
      @host = resource_finder(::Host::Managed.authorized(permission, ::Host::Managed), id)
      fail HttpErrors::BadRequest, _("Host has not been registered with subscription-manager") if @host.subscription_facet.nil?
    end

    def check_upstream_connection
      checker = Katello::UpstreamConnectionChecker.new(@organization)

      begin
        checker.assert_connection
      rescue => e
        raise HttpErrors::BadRequest, e.message
      end
    end
  end
end
