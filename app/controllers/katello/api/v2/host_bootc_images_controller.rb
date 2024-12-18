module Katello
  class Api::V2::HostBootcImagesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    api :GET, "/hosts/bootc_images", N_("List booted bootc container images for hosts")
    param :page, :number, :desc => N_("Page number, starting at 1")
    param :per_page, :number, :desc => N_("Number of results per page to return")
    def bootc_images
      bootc_image_map = bootc_host_image_map(params[:search])

      page = params[:page].present? ? params[:page].to_i : 1
      per_page = params[:per_page].present? ? params[:per_page].to_i : Setting[:entries_per_page]
      paged_images = bootc_image_map.to_a.paginate(page: page, per_page: per_page)
      results = paged_images.collect { |image| { image_name: image[0], digests: image[1] } }
      render json: { total: bootc_image_map.size, page: page, per_page: per_page, subtotal: bootc_image_map.size, results: results}
    end

    private

    def index_relation
      query = resource_class.authorized(:view_hosts).distinct
      query.joins(:content_facet).where.not(bootc_booted_image: nil, bootc_booted_digest: nil)
      query
    end

    def resource_class
      ::Host::Managed
    end

    def bootc_host_image_map(host_search)
      # TODO: can this be optimized such that it doesn't require two queries?
      content_facets = ::Katello::Host::ContentFacet.where(host_id: ::Host::Managed.joins(:content_facet).search_for(host_search).pluck(:id))
      aggregate_bootc_data = content_facets.where.not(bootc_booted_image: nil, bootc_booted_digest: nil).
          select(:bootc_booted_image, :bootc_booted_digest, 'COUNT(hosts.id) as host_count').
          joins(:host).group(:bootc_booted_image, :bootc_booted_digest).order(:bootc_booted_image)
      bootc_image_map = Hash.new { |h, k| h[k] = [] }
      aggregate_bootc_data.each do |host_image|
        bootc_image_map[host_image.bootc_booted_image] << { bootc_booted_digest: host_image.bootc_booted_digest, host_count: host_image.host_count.to_i }
      end
      bootc_image_map
    end
  end
end
