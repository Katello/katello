module Katello
  class Api::V2::HostBootcImagesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    api :GET, "/hosts/bootc_images", N_("List booted bootc container images for hosts")
    param_group :search, Api::V2::ApiController
    def bootc_images
      params[:sort_by] ||= 'bootc_booted_image'
      params[:sort_order] ||= 'asc'
      if params[:order]
        params[:order] = "#{params[:order].split(' ')[0]} #{sanitize_sort_order(params[:order].split(' ')[1])}"
      else
        params[:order] = "#{params[:sort_by]} #{sanitize_sort_order(params[:sort_order])}"
      end
      per_page = params[:per_page].present? ? params[:per_page].to_i : Setting[:entries_per_page]
      page = params[:page].present? ? params[:page].to_i : 1

      bootc_image_map = bootc_host_image_map
      paged_images = bootc_image_map.to_a.paginate(page: page, per_page: per_page)
      results = paged_images.collect { |image| { bootc_booted_image: image[0], digests: image[1] } }
      render json: { total: bootc_image_map.size, page: page, per_page: per_page, subtotal: bootc_image_map.size, results: results}
    end

    private

    def sanitize_sort_order(sort_order)
      if sort_order.present? && ['asc', 'desc'].include?(sort_order.downcase)
        sort_order.downcase
      else
        'asc'
      end
    end

    def index_relation
      query = resource_class.authorized(:view_hosts).distinct
      query.joins(:content_facet).where.not(bootc_booted_image: nil, bootc_booted_digest: nil)
      query
    end

    def resource_class
      ::Host::Managed
    end

    def bootc_host_image_map
      content_facets = ::Katello::Host::ContentFacet.where(host_id: ::Host::Managed.joins(:content_facet).search_for(params[:search]).pluck(:id))
      aggregate_bootc_data = content_facets.where.not(bootc_booted_image: nil, bootc_booted_digest: nil).
          select(:bootc_booted_image, :bootc_booted_digest, 'COUNT(hosts.id) as host_count').
          joins(:host).group(:bootc_booted_image, :bootc_booted_digest).order(params[:order])
      bootc_image_map = Hash.new { |h, k| h[k] = [] }
      aggregate_bootc_data.each do |host_image|
        bootc_image_map[host_image.bootc_booted_image] << { bootc_booted_digest: host_image.bootc_booted_digest, host_count: host_image.host_count.to_i }
      end
      bootc_image_map
    end
  end
end
