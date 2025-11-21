module Katello
  class Api::V2::FlatpakRemoteRepositoriesController < Katello::Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_remote_repository, :except => [:index, :auto_complete_search]
    before_action :find_optional_organization, :only => [:index, :auto_complete_search]
    before_action :find_and_validate_product_for_mirroring, :only => [:mirror]

    resource_description do
      name 'Flatpak Remote Repositories'
    end

    def_param_group :flatpak_remote_repositories do
      param :name, String, :desc => N_("Name of the flatpak remote repository")
      param :label, String, :desc => N_("Label of the flatpak remote")
    end

    api :GET, "/organizations/:organization_id/flatpak_remote_repositories", N_("List flatpak remote repositories")
    api :GET, "/flatpak_remotes/:flatpak_remote_id/flatpak_remote_repositories", N_("List flatpak remote's repositories")
    param :organization_id, :number, :desc => N_("organization identifier")
    param :flatpak_remote_id, :number, :desc => N_("ID of flatpak remote to show repositories of"), :required => true
    param_group :flatpak_remote_repositories
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(FlatpakRemoteRepository)
    def index
      respond(:collection => scoped_search(index_relation, :name, :asc))
    end

    def index_relation
      query = FlatpakRemoteRepository.readable
      query = index_remote_relation(query)
      query = query.where(name: params[:name]) if params[:name]
      query = query.where(label: params[:label]) if params[:label]
      query
    end

    def index_remote_relation(query)
      query = query.joins(:flatpak_remote).where("#{FlatpakRemote.table_name}.organization_id" => @organization) if @organization
      if params[:flatpak_remote_id]
        query.where(flatpak_remote_id: params[:flatpak_remote_id])
      else
        query
      end
    end

    api :GET, "/flatpak_remote_repositories/:id", N_("Show a flatpak remote repository")
    param :id, :number, :desc => N_("Flatpak remote repository numeric identifier"), :required => true
    param :manifests, :boolean, :desc => N_("Include manifests"), :required => false
    def show
      respond :resource => @flatpak_remote_repository
    end

    api :POST, "/flatpak_remote_repositories/:id/mirror", N_("Mirror a flatpak remote repository")
    param :id, :number, :desc => N_("Flatpak remote repository numeric identifier"), :required => true
    param :product_id, :number, :desc => N_("Product ID to mirror the remote repository to")
    param :product_name, String, :desc => N_("Name of the product to mirror the remote repository to")
    param :organization_id, :number, :desc => N_("organization identifier")
    param :dependency_ids, Array, :desc => N_("Array of dependency repository IDs to mirror along with the main repository")
    def mirror
      # Collect all repositories to mirror (dependencies + main)
      repos_to_mirror = params[:dependency_ids].present? ? find_dependency_repositories.to_a : []
      repos_to_mirror << @flatpak_remote_repository

      task = async_task(::Actions::BulkAction,
                        ::Actions::Katello::Flatpak::MirrorRemoteRepository,
                        repos_to_mirror,
                        @product.id)

      respond_for_async :resource => task
    end

    def default_sort
      %w(name asc)
    end

    def flatpak_remote_repository_params
      params.require(:flatpak_remote_repository).permit(:name, :label, :flatpak_remote_id)
    end

    def find_remote_repository
      @flatpak_remote_repository = FlatpakRemoteRepository.find(params[:id])
      throw_resource_not_found(name: 'flatpak_remote_repository', id: params[:id]) unless @flatpak_remote_repository
      @flatpak_remote_repository
    end

    protected

    def rejected_autocomplete_items
      ['flatpak_remote_id', 'flatpak_remote']
    end

    private

    def find_dependency_repositories
      dependency_ids = params[:dependency_ids] || []
      repos = FlatpakRemoteRepository.readable.where(id: dependency_ids)

      if repos.count != dependency_ids.count
        missing_ids = dependency_ids - repos.pluck(:id)
        msg = _("Could not find dependency repositories with IDs: %{ids}. Proceeding with found repositories.") % { ids: missing_ids.join(', ') }
        Rails.logger.debug(msg)
      end

      repos
    end

    def find_and_validate_product_for_mirroring
      if params[:product_id]
        @product = Product.editable.find(params[:product_id]) # will throw not found if id is invalid
      elsif params[:product_name] && params[:organization_id]
        @product = Product.editable.find_by(name: params[:product_name], organization_id: params[:organization_id])
        unless @product
          msg = _("Could not find product with name '%{name}' in organization id %{org_id}.") %
                  { name: params[:product_name], org_id: params[:organization_id] }
          fail HttpErrors::NotFound, msg
        end
      elsif params[:product_name]
        msg = _("Organization must be specified when providing product by name.")
        fail HttpErrors::BadRequest, msg
      else
        msg = _("Product must be specified.")
        fail HttpErrors::BadRequest, msg
      end

      if @product.redhat?
        msg = _("Flatpak repositories cannot be mirrored into Red Hat products. Please select a custom product.")
        fail HttpErrors::UnprocessableEntity, msg
      end
    end
  end
end
