module Katello
  class Api::V2::ApiController < ::Api::V2::BaseController
    include Concerns::Api::ApiController
    include Api::Version2
    include Api::V2::Rendering
    include Api::V2::ErrorHandling

    # support for session (thread-local) variables must be the last filter in this class
    include Foreman::ThreadSession::Cleaner

    skip_before_action :setup_has_many_params # TODO: get this working #8862

    resource_description do
      api_version 'v2'
      api_base_url "/katello/api"
    end

    def_param_group :search do
      param :search, String, :desc => N_("Search string")
      param :page, :number, :desc => N_("Page number, starting at 1")
      param :per_page, :number, :desc => N_("Number of results per page to return")
      param :order, String, :desc => N_("Sort field and order, eg. 'name DESC'")
      param :full_result, :bool, :desc => N_("Whether or not to show all results")
      param :sort, Hash, :desc => N_("Hash version of 'order' param") do
        param :by, String, :desc => N_("Field to sort the results on")
        param :order, String, :desc => N_("How to order the sorted results (e.g. ASC for ascending)")
      end
    end

    param :object_root, String, :desc => N_("root-node of single-resource responses (optional)")
    param :root_name, String, :desc => N_("root-node of collection contained in responses (default: 'results')")

    def resource_class
      @resource_class ||= resource_name.classify.constantize
    rescue NameError
      @resource_class ||= "Katello::#{resource_name.classify}".constantize
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
    # rubocop:disable Metrics/PerceivedComplexity
    def scoped_search(query, default_sort_by, default_sort_order, options = {})
      resource = options[:resource_class] || resource_class
      includes = options.fetch(:includes, [])
      group = options.fetch(:group, nil)

      total = scoped_search_total(query, group)

      unless empty_search_query?
        query = query.pluck(:id) if query.respond_to?(:pluck)
        query = resource.search_for(*search_options).where("#{resource.table_name}.id" => query)
      end

      query = query.select(group).group(group) if group
      sub_total = total.zero? ? 0 : scoped_search_total(query, group)

      sort_attr = params[:sort_by] || default_sort_by

      if sort_attr
        sort_order = (params[:sort_order] || default_sort_order).to_s.downcase
        sort_order = default_sort_order unless ['desc', 'asc'].include?(sort_order)
        query = query.order(sort_attr => sort_order.to_sym)
      elsif options[:custom_sort]
        query = options[:custom_sort].call(query)
      end
      query = query.order("#{query.table_name}.id DESC") unless group #secondary order to ensure sort is deterministic
      query = query.includes(includes) if includes.length > 0

      if ::Foreman::Cast.to_bool(params[:full_result])
        params[:per_page] = total
      else
        query = query.paginate(paginate_options)
      end
      page = params[:page] || 1
      per_page = params[:per_page] || Setting[:entries_per_page]
      query = (total.zero? || sub_total.zero?) ? [] : query

      scoped_search_results(query, sub_total, total, page, per_page)
    rescue ScopedSearch::QueryNotSupported => error
      return scoped_search_results(query, sub_total, total, page, per_page, error.message)
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
        :results  => query,
        :subtotal => sub_total,
        :total    => total,
        :page     => page,
        :per_page => per_page,
        :error    => error
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

    def find_default_organization_and_or_environment
      return if (params.keys & %w(organization_id owner environment_id host_collection_id)).any?

      if current_user.default_organization.present?
        @organization = current_user.default_organization
        @environment = @organization.library
      else
        fail HttpErrors::NotFound, _("You have not set a default organization on the user %s.") % current_user.login
      end
    end

    def find_host_with_subscriptions(id, permission)
      @host = resource_finder(::Host::Managed.authorized(permission, ::Host::Managed), id)
      fail HttpErrors::BadRequest, _("Host has not been registered with subscription-manager") if @host.subscription_facet.nil?
    end
  end
end
