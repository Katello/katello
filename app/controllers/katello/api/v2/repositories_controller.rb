module Katello
  class Api::V2::RepositoriesController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch

    before_action :find_optional_organization, :only => [:index, :auto_complete_search]
    before_action :find_product, :only => [:index, :auto_complete_search]
    before_action :find_product_for_create, :only => [:create]
    before_action :find_organization_from_product, :only => [:create]
    before_action :find_repository, :only => [:show, :update, :destroy, :sync, :export,
                                              :remove_content, :upload_content, :republish,
                                              :import_uploads, :gpg_key_content]
    before_action :find_content, :only => :remove_content
    before_action :find_organization_from_repo, :only => [:update]
    before_action :find_gpg_key, :only => [:create, :update]
    before_action :error_on_rh_product, :only => [:create]
    before_action :error_on_rh_repo, :only => [:destroy]

    skip_before_action :authorize, :only => [:sync_complete, :gpg_key_content]
    skip_before_action :require_org, :only => [:sync_complete]
    skip_before_action :require_user, :only => [:sync_complete]
    skip_before_action :check_content_type, :only => [:upload_content]

    def_param_group :repo do
      param :name, String, :required => true
      param :label, String, :required => false
      param :product_id, :number, :required => true, :desc => N_("Product the repository belongs to")
      param :url, String, :desc => N_("repository source url")
      param :gpg_key_id, :number, :desc => N_("id of the gpg key that will be assigned to the new repository")
      param :unprotected, :bool, :desc => N_("true if this repository can be published via HTTP")
      param :content_type, RepositoryTypeManager.creatable_repository_types.keys, :required => true, :desc => N_("type of repo (either 'yum', 'puppet', 'docker', or 'ostree')")
      param :checksum_type, String, :desc => N_("checksum of the repository, currently 'sha1' & 'sha256' are supported.")
      param :docker_upstream_name, String, :desc => N_("name of the upstream docker repository")
      param :download_policy, ["immediate", "on_demand", "background"], :desc => N_("download policy for yum repos (either 'immediate', 'on_demand', or 'background')")
      param :mirror_on_sync, :bool, :desc => N_("true if this repository when synced has to be mirrored from the source and stale rpms removed.")
      param :verify_ssl_on_sync, :bool, :desc => N_("if true, Katello will verify the upstream url's SSL certifcates are signed by a trusted CA.")
      param :upstream_username, String, :desc => N_("Username of the upstream repository user used for authentication")
      param :upstream_password, String, :desc => N_("Password of the upstream repository user used for authentication")
      param :ostree_upstream_sync_policy, ::Katello::Repository::OSTREE_UPSTREAM_SYNC_POLICIES, :desc => N_("policies for syncing upstream ostree repositories.")
      param :ostree_upstream_sync_depth, :number, :desc => N_("if a custom sync policy is chosen for ostree repositories then a 'depth' value must be provided.")
    end

    api :GET, "/repositories", N_("List of enabled repositories")
    api :GET, "/content_views/:id/repositories", N_("List of repositories for a content view")
    api :GET, "/organizations/:organization_id/repositories", N_("List of repositories in an organization")
    api :GET, "/organizations/:organization_id/environments/:environment_id/repositories", _("List repositories in the environment")
    api :GET, "/products/:product_id/repositories", N_("List of repositories for a product")
    api :GET, "/environments/:environment_id/products/:product_id/repositories", N_("List of repositories belonging to a product in an environment")
    param :organization_id, :number, :desc => N_("ID of an organization to show repositories in")
    param :product_id, :number, :desc => N_("ID of a product to show repositories of")
    param :environment_id, :number, :desc => N_("ID of an environment to show repositories in")
    param :content_view_id, :number, :desc => N_("ID of a content view to show repositories in")
    param :content_view_version_id, :number, :desc => N_("ID of a content view version to show repositories in")
    param :erratum_id, String, :desc => N_("Id of an erratum to find repositories that contain the erratum")
    param :rpm_id, String, :desc => N_("Id of a package to find repositories that contain the rpm")
    param :ostree_branch_id, String, :desc => N_("Id of an ostree branch to find repositories that contain that branch")
    param :library, :bool, :desc => N_("show repositories in Library and the default content view")
    param :content_type, RepositoryTypeManager.repository_types.keys, :desc => N_("limit to only repositories of this type")
    param :name, String, :desc => N_("name of the repository"), :required => false
    param :available_for, String, :desc => N_("interpret specified object to return only Repositories that can be associated with specified object.  Only 'content_view' is supported."),
          :required => false
    param_group :search, Api::V2::ApiController
    def index
      options = {:includes => [:gpg_key, :product, :environment]}
      respond(:collection => scoped_search(index_relation.uniq, :name, :asc, options))
    end

    def index_relation
      query = Repository.readable
      query = index_relation_product(query)
      query = query.where(:content_type => params[:content_type]) if params[:content_type]
      query = query.where(:name => params[:name]) if params[:name]

      if params[:erratum_id]
        query = query.joins(:errata).where("#{Erratum.table_name}.id" => Erratum.with_identifiers(params[:erratum_id]))
      end

      if params[:rpm_id]
        query = query.joins(:rpms).where("#{Rpm.table_name}.id" => Rpm.with_identifiers(params[:rpm_id]))
      end

      if params[:ostree_branch_id]
        query = query.joins(:ostree_branches).where("#{OstreeBranch.table_name}.id" => OstreeBranch.with_identifiers(params[:ostree_branch_id]))
      end

      if params[:puppet_module_id]
        query = query
                  .joins(:puppet_modules)
                  .where("#{PuppetModule.table_name}.id" => PuppetModule.with_identifiers(params[:puppet_module_id]))
      end

      query = index_relation_content_view(query)
      query = index_relation_environment(query)

      query
    end

    def index_relation_product(query)
      query = query.joins(:product).where("#{Product.table_name}.organization_id" => @organization) if @organization
      query = query.where(:product_id => @product.id) if @product
      query
    end

    def index_relation_content_view(query)
      if params[:content_view_version_id]
        query = query.where(:content_view_version_id => params[:content_view_version_id])
        query = Repository.where(:id => query.map(&:library_instance_id)) if params[:library]
      elsif params[:content_view_id]
        query = filter_by_content_view(query, params[:content_view_id], params[:environment_id], params[:available_for] == 'content_view')
      end
      query
    end

    def index_relation_environment(query)
      if params[:environment_id] && !params[:library]
        query = query.where(:environment_id => params[:environment_id])
      elsif params[:environment_id] && params[:library]
        instances = query.where(:environment_id => params[:environment_id])
        instance_ids = instances.pluck(:library_instance_id).reject(&:blank?)
        instance_ids += instances.where(:library_instance_id => nil)
        query = Repository.where(:id => instance_ids)
      elsif (params[:library] && !params[:environment_id]) || (params[:environment_id].blank? && params[:content_view_version_id].blank? && params[:content_view_id].blank?)

        if @organization
          query = query.where(:content_view_version_id => @organization.default_content_view.versions.first.id)
        else
          query = query.in_default_view
        end
      end
      query
    end

    api :POST, "/repositories", N_("Create a custom repository")
    param_group :repo
    def create
      repo_params = repository_params
      unless RepositoryTypeManager.creatable_by_user?(repo_params[:content_type])
        msg = _("Invalid params provided - content_type must be one of %s") % RepositoryTypeManager.creatable_repository_types.keys.join(",")
        fail HttpErrors::UnprocessableEntity, msg
      end

      gpg_key = @product.gpg_key
      unless repo_params[:gpg_key_id].blank?
        gpg_key = @gpg_key
      end
      repo_params[:label] = labelize_params(repo_params)
      repo_params[:url] = nil if repo_params[:url].blank?
      unprotected =  repo_params.key?(:unprotected) ? repo_params[:unprotected] : true
      repository = @product.add_repo(repo_params[:label], repo_params[:name], repo_params[:url],
                                     repo_params[:content_type], unprotected,
                                     gpg_key, repository_params[:checksum_type], repo_params[:download_policy])
      repository.docker_upstream_name = repo_params[:docker_upstream_name] if repo_params[:docker_upstream_name]
      repository.mirror_on_sync = ::Foreman::Cast.to_bool(repo_params[:mirror_on_sync]) if repo_params.key?(:mirror_on_sync)
      repository.verify_ssl_on_sync = ::Foreman::Cast.to_bool(repo_params[:verify_ssl_on_sync]) if repo_params.key?(:verify_ssl_on_sync)
      repository.upstream_username = repo_params[:upstream_username] if repo_params.key?(:upstream_username)
      repository.upstream_password = repo_params[:upstream_password] if repo_params.key?(:upstream_password)
      if repository.ostree?
        repository.ostree_upstream_sync_policy = repo_params[:ostree_upstream_sync_policy]
        repository.ostree_upstream_sync_depth = repo_params[:ostree_upstream_sync_depth]
      end
      sync_task(::Actions::Katello::Repository::Create, repository, false, true)
      repository = Repository.find(repository.id)
      respond_for_show(:resource => repository)
    end

    api :GET, "/repositories/repository_types", N_("Show the available repository types")
    param :creatable, :bool, :desc => N_("When set to 'True' repository types that are creatable will be returned")
    def repository_types
      creatable = ::Foreman::Cast.to_bool(params[:creatable])
      repo_types = creatable ? RepositoryTypeManager.creatable_repository_types : RepositoryTypeManager.repository_types
      render :json => repo_types.values
    end

    api :PUT, "/repositories/:id/republish", N_("Forces a republish of the specified repository, regenerating metadata and symlinks on the filesystem.")
    param :id, :identifier, :desc => N_("Repository identifier"), :required => true
    def republish
      task = async_task(::Actions::Katello::Repository::MetadataGenerate, @repository, :force => true)
      respond_for_async :resource => task
    end

    api :GET, "/repositories/:id", N_("Show a repository")
    param :id, :identifier, :required => true, :desc => N_("repository ID")
    def show
      respond_for_show(:resource => @repository)
    end

    api :POST, "/repositories/:id/sync", N_("Sync a repository")
    param :id, :identifier, :required => true, :desc => N_("repository ID")
    param :source_url, String, :desc => N_("temporarily override feed URL for sync"), :required => false
    param :incremental, :bool, :desc => N_("perform an incremental import"), :required => false
    param :skip_metadata_check, :bool, :desc => N_("Force sync even if no upstream changes are detected. Only used with yum repositories."), :required => false
    param :validate_contents, :bool, :desc => N_("Force a sync and validate the checksums of all content. Only used with yum repositories."), :required => false
    def sync
      sync_options = {
        :skip_metadata_check => ::Foreman::Cast.to_bool(params[:skip_metadata_check]),
        :validate_contents => ::Foreman::Cast.to_bool(params[:validate_contents]),
        :incremental => ::Foreman::Cast.to_bool(params[:incremental]),
        :source_url => params[:source_url]
      }

      if params[:source_url].present? && params[:source_url] !~ /\A#{URI.regexp}\z/
        fail HttpErrors::BadRequest, _("source URL is malformed")
      end

      if params[:source_url].blank? && @repository.url.blank?
        fail HttpErrors::BadRequest, _("attempted to sync without a feed URL")
      end

      task = async_task(::Actions::Katello::Repository::Sync, @repository, nil, sync_options)
      respond_for_async :resource => task
    rescue Errors::InvalidActionOptionError => e
      raise HttpErrors::BadRequest, e.message
    end

    api :POST, "/repositories/:id/export", N_("Export a repository")
    param :id, :identifier, :desc => N_("Repository identifier"), :required => true
    param :export_to_iso, :bool, :desc => N_("Export to ISO format"), :required => false
    param :iso_mb_size, :number, :desc => N_("maximum size of each ISO in MB"), :required => false
    param :since, Date, :desc => N_("Optional date of last export (ex: 2010-01-01T12:00:00Z)"), :required => false
    def export
      if !params[:export_to_iso].present? && params[:iso_mb_size].present?
        fail HttpErrors::BadRequest, _("ISO export must be enabled when specifying ISO size")
      end

      if params[:since].present?
        begin
          params[:since].to_datetime
        rescue
          raise HttpErrors::BadRequest, _("Invalid date provided.")
        end
      end

      fail HttpErrors::BadRequest, _("Repository content type must be 'yum' to export.") unless @repository.content_type == 'yum'

      task = async_task(::Actions::Katello::Repository::Export, [@repository],
                        ::Foreman::Cast.to_bool(params[:export_to_iso]),
                        params[:since].try(:to_datetime),
                        params[:iso_mb_size],
                        @repository.pulp_id)
      respond_for_async :resource => task
    end

    api :PUT, "/repositories/:id", N_("Update a repository")
    param :name, String, :desc => N_("New name for the repository")
    param :id, :identifier, :required => true, :desc => N_("repository ID")
    param :gpg_key_id, :number, :desc => N_("ID of a gpg key that will be assigned to this repository")
    param :unprotected, :bool, :desc => N_("true if this repository can be published via HTTP")
    param :checksum_type, String, :desc => N_("checksum of the repository, currently 'sha1' & 'sha256' are supported.'")
    param :url, String, :desc => N_("the feed url of the original repository ")
    param :docker_upstream_name, String, :desc => N_("name of the upstream docker repository")
    param :download_policy, ["immediate", "on_demand", "background"], :desc => N_("download policy for yum repos (either 'immediate', 'on_demand', or 'background')")
    param :mirror_on_sync, :bool, :desc => N_("true if this repository when synced has to be mirrored from the source and stale rpms removed.")
    param :verify_ssl_on_sync, :bool, :desc => N_("if true, Katello will verify the upstream url's SSL certifcates are signed by a trusted CA.")
    param :upstream_username, String, :desc => N_("Username of the upstream repository user for authentication")
    param :upstream_password, String, :desc => N_("Password of the upstream repository user for authentication")
    param :ostree_upstream_sync_policy, ::Katello::Repository::OSTREE_UPSTREAM_SYNC_POLICIES, :desc => N_("policies for syncing upstream ostree repositories.")
    param :ostree_upstream_sync_depth, :number, :desc => N_("if a custom sync policy is chosen for ostree repositories then a 'depth' value must be provided.")
    def update
      repo_params = repository_params
      sync_task(::Actions::Katello::Repository::Update, @repository, repo_params)
      respond_for_show(:resource => @repository)
    end

    api :DELETE, "/repositories/:id", N_("Destroy a custom repository")
    param :id, :identifier, :required => true
    def destroy
      sync_task(::Actions::Katello::Repository::Destroy, @repository)
      respond_for_destroy
    end

    api :POST, "/repositories/sync_complete"
    desc N_("URL for post sync notification from pulp")
    param 'token', String, :desc => N_("shared secret token"), :required => true
    param 'payload', Hash, :required => true do
      param 'repo_id', String, :required => true
    end
    param 'call_report', Hash, :required => true do
      param 'task_id', String, :required => true
    end
    def sync_complete
      if params[:token] != Rack::Utils.parse_query(URI(SETTINGS[:katello][:post_sync_url]).query)['token']
        fail Errors::SecurityViolation, _("Token invalid during sync_complete.")
      end

      repo_id = params['payload']['repo_id']
      task_id = params['call_report']['task_id']
      User.current = User.anonymous_admin

      repo = Repository.where(:pulp_id => repo_id).first
      fail _("Couldn't find repository '%s'") % repo_id if repo.nil?
      Rails.logger.info("Sync_complete called for #{repo.name}, running after_sync.")

      unless repo.dynflow_handled_last_sync?(task_id)
        async_task(::Actions::Katello::Repository::Sync, repo, task_id)
      end
      render :json => {}
    end

    api :PUT, "/repositories/:id/remove_packages"
    api :PUT, "/repositories/:id/remove_docker_manifests"
    api :PUT, "/repositories/:id/remove_puppet_modules"
    api :PUT, "/repositories/:id/remove_content"
    desc "Remove content from a repository"
    param :id, :identifier, :required => true, :desc => "repository ID"
    param 'ids', Array, :required => true, :desc => "Array of content ids to remove"
    param 'sync_capsule', :bool, :desc => N_("Whether or not to sync an external capsule after upload. Default: true")
    def remove_content
      sync_capsule = ::Foreman::Cast.to_bool(params.fetch(:sync_capsule, true))
      fail _("No content ids provided") if @content.blank?
      respond_for_async :resource => sync_task(::Actions::Katello::Repository::RemoveContent, @repository, @content, sync_capsule: sync_capsule)
    end

    api :POST, "/repositories/:id/upload_content", N_("Upload content into the repository")
    param :id, :identifier, :required => true, :desc => N_("repository ID")
    param :content, File, :required => true, :desc => N_("Content files to upload. Can be a single file or array of files.")
    def upload_content
      fail Katello::Errors::InvalidRepositoryContent, _("Cannot upload Docker content.") if @repository.docker?

      filepaths = Array.wrap(params[:content]).compact.collect do |content|
        {path: content.path, filename: content.original_filename}
      end

      if !filepaths.blank?
        sync_task(::Actions::Katello::Repository::UploadFiles, @repository, filepaths)
        render :json => {:status => "success", :filenames => filepaths.map { |item| item[:filename] }}
      else
        fail HttpErrors::BadRequest, _("No file uploaded")
      end

    rescue Katello::Errors::InvalidRepositoryContent => error
      respond_for_exception(
        error,
        :status => :unprocessable_entity,
        :text => error.message,
        :errors => [error.message],
        :with_logging => true
      )
    end

    api :PUT, "/repositories/:id/import_uploads", N_("Import uploads into a repository")
    param :id, :identifier, :required => true, :desc => N_("Repository id")
    param :upload_ids, Array, :desc => N_("Array of upload ids to import"), :deprecated => true
    param :async, :bool, desc: N_("Do not wait for the ImportUpload action to finish. Default: false")
    param 'publish_repository', :bool, :desc => N_("Whether or not to regenerate the repository on disk. Default: true")
    param 'sync_capsule', :bool, :desc => N_("Whether or not to sync an external capsule after upload. Default: true")
    param :uploads, Array, :desc => N_("Array of uploads to import") do
      param 'id', String, :required => true
      param 'size', String
      param 'checksum', String
      param 'name', String, :desc => N_("Needs to only be set for file repositories")
    end
    def import_uploads
      generate_metadata = ::Foreman::Cast.to_bool(params.fetch(:publish_repository, true))
      sync_capsule = ::Foreman::Cast.to_bool(params.fetch(:sync_capsule, true))
      async = ::Foreman::Cast.to_bool(params.fetch(:async, false))
      if params['upload_ids'].empty? && params['uploads'].empty?
        fail HttpErrors::BadRequest, _('No upload param specified. Either uploads or upload_ids (deprecated) is required.')
      end

      uploads = params['uploads'] || []

      if params.key?(:upload_ids)
        ::Foreman::Deprecation.api_deprecation_warning("The parameter upload_ids will be removed in Katello 3.3. Please update to use the uploads parameter.")
        params[:upload_ids].each { |upload_id| uploads << {'id' => upload_id} }
      end

      upload_ids = uploads.map { |upload| upload['id'] }
      unit_keys = uploads.map do |upload|
        if @repository.file?
          upload.except('id')
        else
          upload.except('id').except('name')
        end
      end

      begin
        task = send(async ? :async_task : :sync_task, ::Actions::Katello::Repository::ImportUpload,
                    @repository, upload_ids, :unit_keys => unit_keys,
                    :generate_metadata => generate_metadata, :sync_capsule => sync_capsule)
        respond_for_async(resource: task)
      rescue => e
        raise HttpErrors::BadRequest, e.message
      end
    end

    # returns the content of a repo gpg key, used directly by yum
    # we don't want to authenticate, authorize etc, trying to distinguish between a yum request and normal api request
    # might not always be 100% bullet proof, and its more important that yum can fetch the key.
    api :GET, "/repositories/:id/gpg_key_content", N_("Return the content of a repo gpg key, used directly by yum")
    param :id, :identifier, :required => true
    def gpg_key_content
      if @repository.gpg_key && @repository.gpg_key.content.present?
        render(:text => @repository.gpg_key.content, :layout => false)
      else
        head(404)
      end
    end

    protected

    def find_product
      @product = Product.find(params[:product_id]) if params[:product_id]
      find_organization_from_product if @organization.nil? && @product
    end

    def find_product_for_create
      @product = Product.find(params[:product_id])
    end

    def find_repository
      @repository = Repository.find(params[:id])
    end

    def find_gpg_key
      if params[:gpg_key_id]
        @gpg_key = GpgKey.readable.where(:id => params[:gpg_key_id], :organization_id => @organization).first
        fail HttpErrors::NotFound, _("Couldn't find gpg key '%s'") % params[:gpg_key_id] if @gpg_key.nil?
      end
    end

    def repository_params
      keys = [:download_policy, :mirror_on_sync, :verify_ssl_on_sync, :upstream_password, :upstream_username,
              :ostree_upstream_sync_depth, :ostree_upstream_sync_policy
             ]
      keys += [:label, :content_type] if params[:action] == "create"
      if params[:action] == 'create' || @repository.custom?
        keys += [:url, :gpg_key_id, :unprotected, :name, :checksum_type, :docker_upstream_name]
      end
      params.require(:repository).permit(*keys)
    end

    def error_on_rh_product
      fail HttpErrors::BadRequest, _("Red Hat products cannot be manipulated.") if @product.redhat?
    end

    def error_on_rh_repo
      fail HttpErrors::BadRequest, _("Red Hat repositories cannot be manipulated.") if @repository.redhat?
    end

    def find_organization_from_repo
      @organization = @repository.organization
    end

    def find_organization_from_product
      @organization = @product.organization
    end

    def find_content
      @content = @repository.units_for_removal(params[:ids])
    end

    def filter_by_content_view(query, content_view_id, environment_id, is_available_for)
      if is_available_for
        params[:library] = true
        sub_query = ContentViewRepository.where(:content_view_id => content_view_id).pluck(:repository_id)
        query = query.where("#{Repository.table_name}.id not in (#{sub_query.join(',')})") unless sub_query.empty?
      elsif environment_id
        version = ContentViewVersion.in_environment(environment_id).where(:content_view_id => content_view_id)
        query = query.where(:content_view_version_id => version)
      else
        query = query.joins(:content_view_repositories).where("#{ContentViewRepository.table_name}.content_view_id" => content_view_id)
      end
      query
    end
  end
end
