module Katello
  class Api::V2::RepositoriesController < Api::V2::ApiController # rubocop:disable Metrics/ClassLength
    include Katello::Concerns::FilteredAutoCompleteSearch

    wrap_parameters :repository, :include => RootRepository.attribute_names.concat([:ignore_global_proxy])

    CONTENT_CREDENTIAL_GPG_KEY_TYPE = "gpg_key".freeze
    CONTENT_CREDENTIAL_SSL_CA_CERT_TYPE = "ssl_ca_cert".freeze
    CONTENT_CREDENTIAL_SSL_CLIENT_CERT_TYPE = "ssl_client_cert".freeze
    CONTENT_CREDENTIAL_SSL_CLIENT_KEY_TYPE = "ssl_client_key".freeze

    before_action :find_optional_organization, :only => [:index, :auto_complete_search]
    before_action :find_product, :only => [:index, :auto_complete_search]
    before_action :find_product_for_create, :only => [:create]
    before_action :find_organization_from_product, :only => [:create]
    before_action :find_repository, :only => [:show, :update, :destroy, :sync, :export,
                                              :remove_content, :upload_content, :republish,
                                              :import_uploads, :gpg_key_content]
    before_action :find_content, :only => :remove_content
    before_action :find_organization_from_repo, :only => [:update]
    before_action :error_on_rh_product, :only => [:create]
    before_action :error_on_rh_repo, :only => [:destroy]
    before_action(:only => [:create, :update]) { find_content_credential CONTENT_CREDENTIAL_GPG_KEY_TYPE }
    before_action(:only => [:create, :update]) { find_content_credential CONTENT_CREDENTIAL_SSL_CA_CERT_TYPE }
    before_action(:only => [:create, :update]) { find_content_credential CONTENT_CREDENTIAL_SSL_CLIENT_CERT_TYPE }
    before_action(:only => [:create, :update]) { find_content_credential CONTENT_CREDENTIAL_SSL_CLIENT_KEY_TYPE }
    before_action :check_ignore_global_proxy, :only => [ :update, :create ]
    skip_before_action :authorize, :only => [:gpg_key_content]
    skip_before_action :check_content_type, :only => [:upload_content]

    def custom_index_relation(collection)
      collection.includes(:product)
    end

    def_param_group :repo do
      param :url, String, :desc => N_("repository source url")
      param :gpg_key_id, :number, :desc => N_("id of the gpg key that will be assigned to the new repository")
      param :ssl_ca_cert_id, :number, :desc => N_("Identifier of the content credential containing the SSL CA Cert")
      param :ssl_client_cert_id, :number, :desc => N_("Identifier of the content credential containing the SSL Client Cert")
      param :ssl_client_key_id, :number, :desc => N_("Identifier of the content credential containing the SSL Client Key")
      param :unprotected, :bool, :desc => N_("true if this repository can be published via HTTP")
      param :checksum_type, String, :desc => N_("Checksum of the repository, currently 'sha1' & 'sha256' are supported")
      param :docker_upstream_name, String, :desc => N_("Name of the upstream docker repository")
      param :docker_tags_whitelist, Array, :desc => N_("Comma separated list of tags to sync for Container Image repository")
      param :download_policy, ["immediate", "on_demand", "background"], :desc => N_("download policy for yum repos (either 'immediate', 'on_demand', or 'background (deprecated)')")
      param :mirror_on_sync, :bool, :desc => N_("true if this repository when synced has to be mirrored from the source and stale rpms removed")
      param :verify_ssl_on_sync, :bool, :desc => N_("if true, Katello will verify the upstream url's SSL certifcates are signed by a trusted CA")
      param :upstream_username, String, :desc => N_("Username of the upstream repository user used for authentication")
      param :upstream_password, String, :desc => N_("Password of the upstream repository user used for authentication")
      param :ostree_upstream_sync_policy, ::Katello::RootRepository::OSTREE_UPSTREAM_SYNC_POLICIES, :desc => N_("policies for syncing upstream ostree repositories")
      param :ostree_upstream_sync_depth, :number, :desc => N_("if a custom sync policy is chosen for ostree repositories then a 'depth' value must be provided")
      param :deb_releases, String, :desc => N_("comma separated list of releases to be synched from deb-archive")
      param :deb_components, String, :desc => N_("comma separated list of repo components to be synched from deb-archive")
      param :deb_architectures, String, :desc => N_("comma separated list of architectures to be synched from deb-archive")
      param :ignore_global_proxy, :bool, :desc => N_("if true, will ignore the globally configured proxy when syncing"), :deprecated => true
      param :ignorable_content, Array, :desc => N_("List of content units to ignore while syncing a yum repository. Must be subset of %s") % RootRepository::IGNORABLE_CONTENT_UNIT_TYPES.join(",")
      param :ansible_collection_requirements, String, :desc => N_("Contents of requirement yaml file to sync from URL")
      param :http_proxy_policy, ::Katello::RootRepository::HTTP_PROXY_POLICIES, :desc => N_("policies for HTTP proxy for content sync")
      param :http_proxy_id, :number, :desc => N_("ID of a HTTP Proxy")
    end

    def_param_group :repo_create do
      param :label, String, :required => false
      param :product_id, :number, :required => true, :desc => N_("Product the repository belongs to")
      param :content_type, RepositoryTypeManager.creatable_repository_types.keys, :required => true, :desc => N_("type of repo")
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
    param :deb_id, String, :desc => N_("Id of a deb package to find repositories that contain the deb")
    param :erratum_id, String, :desc => N_("Id of an erratum to find repositories that contain the erratum")
    param :rpm_id, String, :desc => N_("Id of a rpm package to find repositories that contain the rpm")
    param :file_id, String, :desc => N_("Id of a file to find repositories that contain the file")
    param :ansible_collection_id, String, :desc => N_("Id of an ansible collection to find repositories that contain the ansible collection")
    param :ostree_branch_id, String, :desc => N_("Id of an ostree branch to find repositories that contain that branch")
    param :library, :bool, :desc => N_("show repositories in Library and the default content view")
    param :archived, :bool, :desc => N_("show archived repositories")
    param :content_type, RepositoryTypeManager.repository_types.keys, :desc => N_("limit to only repositories of this type")
    param :name, String, :desc => N_("name of the repository"), :required => false
    param :label, String, :desc => N_("label of the repository"), :required => false
    param :description, String, :desc => N_("description of the repository")
    param :available_for, String, :desc => N_("interpret specified object to return only Repositories that can be associated with specified object.  Only 'content_view' & 'content_view_version' are supported."),
          :required => false
    param :with_content, RepositoryTypeManager.enabled_content_types, :desc => N_("only repositories having at least one of the specified content type ex: rpm , erratum")
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(Repository)
    def index
      base_args = [index_relation.distinct, :name, :asc]
      options = {:includes => [:environment, {:root => [:gpg_key, :product]}]}

      respond_to do |format|
        format.csv do
          options[:csv] = true
          repos = scoped_search(*base_args, options)
          csv_response(repos,
                       [:id, :name, :description, :label, :content_type, :arch, :url, :major, :minor,
                        :content_label, :pulp_id, :container_repository_name,
                        :download_policy, 'relative_path', 'product.id', 'product.name',
                        'environment_id'],
                       ['Id', 'Name', 'Description', 'label', 'Content Type', 'Arch', 'Url', 'Major', 'Minor',
                        'Content Label', 'Pulp Id', 'Container Repository Name', 'Download Policy', 'Relative Path',
                        'Product Id', 'Product Name',
                        'Environment Id'])
        end
        format.any do
          repos = scoped_search(*base_args, options)
          respond(:collection => repos)
        end
      end
    end

    def index_relation
      query = Repository.readable
      query = query.with_content(params[:with_content]) if params[:with_content]
      query = index_relation_product(query)
      query = query.with_type(params[:content_type]) if params[:content_type]
      query = query.where(:root_id => RootRepository.where(:name => params[:name])) if params[:name]
      query = query.where(:root_id => RootRepository.where(:label => params[:label])) if params[:label]
      query = index_relation_content_unit(query)
      query = index_relation_content_view(query)
      query = index_relation_environment(query)
      query
    end

    def index_relation_product(query)
      query = query.joins(:root => :product).where("#{Product.table_name}.organization_id" => @organization) if @organization
      query = query.joins(:root).where("#{RootRepository.table_name}.product_id" => @product.id) if @product
      query
    end

    def index_relation_content_view(query)
      if params[:content_view_version_id]
        query = query.where(:content_view_version_id => params[:content_view_version_id])
        query = query.archived if ::Foreman::Cast.to_bool params[:archived]
        query = Katello::Repository.where(:id => query.select(:library_instance_id)) if params[:library]
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
        if params[:available_for] == 'content_view_version'
          query = query.where.not(:content_view_version_id => nil, :environment_id => nil)
        elsif @organization
          query = query.where(:content_view_version_id => @organization.default_content_view.versions.first.id)
        else
          query = query.in_default_view
        end
      end
      query
    end

    def index_relation_content_unit(query)
      if params[:deb_id]
        query = query.joins(:debs)
          .where("#{Deb.table_name}.id" => Deb.with_identifiers(params[:deb_id]))
      end

      if params[:erratum_id]
        query = query.joins(:errata)
          .where("#{Erratum.table_name}.id" => Erratum.with_identifiers(params[:erratum_id]))
      end

      if params[:rpm_id]
        query = query.joins(:rpms)
          .where("#{Rpm.table_name}.id" => Rpm.with_identifiers(params[:rpm_id]))
      end

      if params[:file_id]
        query = query.joins(:files)
          .where("#{FileUnit.table_name}.id" => FileUnit.with_identifiers(params[:file_id]))
      end

      if params[:ansible_collection_id]
        query = query.joins(:ansible_collections)
                    .where("#{AnsibleCollection.table_name}.id" => AnsibleCollection.with_identifiers(params[:ansible_collection_id]))
      end

      if params[:ostree_branch_id]
        query = query.joins(:ostree_branches)
          .where("#{OstreeBranch.table_name}.id" => OstreeBranch.with_identifiers(params[:ostree_branch_id]))
      end

      if params[:puppet_module_id]
        query = query
                  .joins(:puppet_modules)
                  .where("#{PuppetModule.table_name}.id" => PuppetModule.with_identifiers(params[:puppet_module_id]))
      end

      query
    end

    api :POST, "/repositories", N_("Create a custom repository")
    param :name, String, :required => true
    param_group :repo_create
    param_group :repo
    def create
      repo_params = repository_params
      unless RepositoryTypeManager.creatable_by_user?(repo_params[:content_type])
        msg = _("Invalid params provided - content_type must be one of %s") % RepositoryTypeManager.creatable_repository_types.keys.join(",")
        fail HttpErrors::UnprocessableEntity, msg
      end

      if repo_params['content_type'] == "puppet" || repo_params['content_type'] == "ostree"
        ::Foreman::Deprecation.api_deprecation_warning("Puppet and OSTree will no longer be supported in Katello 3.16")
      end

      gpg_key = get_content_credential(repo_params, CONTENT_CREDENTIAL_GPG_KEY_TYPE)
      ssl_ca_cert = get_content_credential(repo_params, CONTENT_CREDENTIAL_SSL_CA_CERT_TYPE)
      ssl_client_cert = get_content_credential(repo_params, CONTENT_CREDENTIAL_SSL_CLIENT_CERT_TYPE)
      ssl_client_key = get_content_credential(repo_params, CONTENT_CREDENTIAL_SSL_CLIENT_KEY_TYPE)

      repo_params[:label] = labelize_params(repo_params)
      repo_params[:arch] = repo_params[:arch] || 'noarch'
      repo_params[:url] = nil if repo_params[:url].blank?
      repo_params[:unprotected] = repo_params.key?(:unprotected) ? repo_params[:unprotected] : true
      repo_params[:gpg_key] = gpg_key
      repo_params[:ssl_ca_cert] = ssl_ca_cert
      repo_params[:ssl_client_cert] = ssl_client_cert
      repo_params[:ssl_client_key] = ssl_client_key

      root = construct_repo_from_params(repo_params)
      sync_task(::Actions::Katello::Repository::CreateRoot, root)
      @repository = root.reload.library_instance
      respond_for_create(:resource => @repository)
    end

    api :GET, "/repositories/repository_types", N_("Show the available repository types")
    param :creatable, :bool, :desc => N_("When set to 'True' repository types that are creatable will be returned")
    def repository_types
      creatable = ::Foreman::Cast.to_bool(params[:creatable])
      repo_types = creatable ? RepositoryTypeManager.creatable_repository_types : RepositoryTypeManager.repository_types
      render :json => repo_types.values
    end

    api :PUT, "/repositories/:id/republish", N_("Forces a republish of the specified repository, regenerating metadata and symlinks on the filesystem.")
    param :id, :number, :desc => N_("Repository identifier"), :required => true
    def republish
      task = async_task(::Actions::Katello::Repository::MetadataGenerate, @repository, :force => true)
      respond_for_async :resource => task
    end

    api :GET, "/repositories/:id", N_("Show a repository")
    param :id, :number, :required => true, :desc => N_("repository ID")
    param :organization_id, :number, :desc => N_("Organization ID")
    def show
      respond_for_show(:resource => @repository)
    end

    api :POST, "/repositories/:id/sync", N_("Sync a repository")
    param :id, :number, :required => true, :desc => N_("repository ID")
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

      if params[:source_url].present? && params[:source_url] !~ /\A#{URI::DEFAULT_PARSER.make_regexp}\z/
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
    param :id, :number, :desc => N_("Repository identifier"), :required => true
    param :export_to_iso, :bool, :desc => N_("Export to ISO format"), :required => false
    param :iso_mb_size, :number, :desc => N_("maximum size of each ISO in MB"), :required => false
    param :since, Date, :desc => N_("Optional date of last export (ex: 2010-01-01T12:00:00Z)"), :required => false
    def export
      if params[:export_to_iso].blank? && params[:iso_mb_size].present?
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

      fail HttpErrors::BadRequest, _("On demand repositories cannot be exported.") if @repository.download_policy == ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND

      task = async_task(::Actions::Katello::Repository::Export, [@repository],
                        ::Foreman::Cast.to_bool(params[:export_to_iso]),
                        params[:since].try(:to_datetime),
                        params[:iso_mb_size],
                        @repository.pulp_id)
      respond_for_async :resource => task
    end

    api :PUT, "/repositories/:id", N_("Update a repository")
    param :id, :number, :required => true, :desc => N_("repository ID")
    param :name, String, :required => false
    param_group :repo
    def update
      repo_params = repository_params

      sync_task(::Actions::Katello::Repository::Update, @repository.root, repo_params)
      respond_for_show(:resource => @repository)
    end

    api :DELETE, "/repositories/:id", N_("Destroy a custom repository")
    param :id, :number, :required => true
    def destroy
      sync_task(::Actions::Katello::Repository::Destroy, @repository)
      respond_for_destroy
    end

    api :PUT, "/repositories/:id/remove_packages"
    api :PUT, "/repositories/:id/remove_docker_manifests"
    api :PUT, "/repositories/:id/remove_puppet_modules"
    api :PUT, "/repositories/:id/remove_content"
    desc "Remove content from a repository"
    param :id, :number, :required => true, :desc => "repository ID"
    param 'ids', Array, :required => true, :desc => "Array of content ids to remove"
    param :content_type, RepositoryTypeManager.removable_content_types.map(&:label), :required => false, :desc => N_("content type ('deb', 'docker_manifest', 'file', 'ostree', 'puppet_module', 'rpm', 'srpm')")
    param 'sync_capsule', :bool, :desc => N_("Whether or not to sync an external capsule after upload. Default: true")
    def remove_content
      sync_capsule = ::Foreman::Cast.to_bool(params.fetch(:sync_capsule, true))
      fail _("No content ids provided") if @content.blank?
      respond_for_async :resource => sync_task(::Actions::Katello::Repository::RemoveContent, @repository, @content, content_type: params[:content_type], sync_capsule: sync_capsule)
    end

    api :POST, "/repositories/:id/upload_content", N_("Upload content into the repository")
    param :id, :number, :required => true, :desc => N_("repository ID")
    param :content, File, :required => true, :desc => N_("Content files to upload. Can be a single file or array of files.")
    param :content_type, RepositoryTypeManager.uploadable_content_types.map(&:label), :required => false, :desc => N_("content type ('deb', 'docker_manifest', 'file', 'ostree', 'puppet_module', 'rpm', 'srpm')")
    def upload_content
      fail Katello::Errors::InvalidRepositoryContent, _("Cannot upload Container Image content.") if @repository.docker?

      filepaths = Array.wrap(params[:content]).compact.collect do |content|
        {path: content.path, filename: content.original_filename}
      end

      if !filepaths.blank?
        sync_task(::Actions::Katello::Repository::UploadFiles, @repository, filepaths, params[:content_type])
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
    param :id, :number, :required => true, :desc => N_("Repository id")
    param :async, :bool, desc: N_("Do not wait for the ImportUpload action to finish. Default: false")
    param 'publish_repository', :bool, :desc => N_("Whether or not to regenerate the repository on disk. Default: true")
    param 'sync_capsule', :bool, :desc => N_("Whether or not to sync an external capsule after upload. Default: true")
    param :content_type, RepositoryTypeManager.uploadable_content_types.map(&:label), :required => false, :desc => N_("content type ('deb', 'docker_manifest', 'file', 'ostree', 'puppet_module', 'rpm', 'srpm')")
    param :uploads, Array, :desc => N_("Array of uploads to import") do
      param 'id', String, :required => true
      param 'content_unit_id', String
      param 'size', String
      param 'checksum', String
      param 'name', String, :desc => N_("Needs to only be set for file repositories or docker tags")
      param 'digest', String, :desc => N_("Needs to only be set for docker tags")
    end
    def import_uploads
      generate_metadata = ::Foreman::Cast.to_bool(params.fetch(:publish_repository, true))
      sync_capsule = ::Foreman::Cast.to_bool(params.fetch(:sync_capsule, true))
      async = ::Foreman::Cast.to_bool(params.fetch(:async, false))
      if params['uploads'].empty?
        fail HttpErrors::BadRequest, _('No uploads param specified. An array of uploads to import is required.')
      end

      uploads = (params[:uploads] || []).map do |upload|
        upload.permit(:id, :content_unit_id, :size, :checksum, :name, :digest).to_h
      end

      begin
        respond_for_async(resource: send(
          async ? :async_task : :sync_task,
          ::Actions::Katello::Repository::ImportUpload, @repository, uploads,
          generate_metadata: generate_metadata, sync_capsule: sync_capsule, content_type: params[:content_type]))
      rescue => e
        raise HttpErrors::BadRequest, e.message
      end
    end

    # returns the content of a repo gpg key, used directly by yum
    # we don't want to authenticate, authorize etc, trying to distinguish between a yum request and normal api request
    # might not always be 100% bullet proof, and its more important that yum can fetch the key.
    api :GET, "/repositories/:id/gpg_key_content", N_("Return the content of a repo gpg key, used directly by yum")
    param :id, :number, :required => true
    def gpg_key_content
      if @repository.root.gpg_key && @repository.root.gpg_key.content.present?
        render(:plain => @repository.root.gpg_key.content, :layout => false)
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

    def find_content_credential(content_type)
      credential_id = "#{content_type}_id".to_sym
      credential_var = "@#{content_type}"

      if params[credential_id]
        credential_value = GpgKey.readable.where(:id => params[credential_id], :organization_id => @organization).first
        instance_variable_set(credential_var, credential_value)
        if instance_variable_get(credential_var).nil?
          fail HttpErrors::NotFound, _("Couldn't find %{content_type} with id '%{id}'") % { :content_type => content_type, :id => params[credential_id] }
        end
      end
    end

    def repository_params
      keys = [:download_policy, :mirror_on_sync, :arch, :verify_ssl_on_sync, :upstream_password, :upstream_username,
              :ostree_upstream_sync_depth, :ostree_upstream_sync_policy,
              :deb_releases, :deb_components, :deb_architectures, :description, :http_proxy_policy, :http_proxy_id,
              {:ignorable_content => []}
             ]

      keys += [{:docker_tags_whitelist => []}, :docker_upstream_name] if params[:action] == 'create' || @repository&.docker?
      keys += [:ansible_collection_requirements] if params[:action] == 'create' || @repository&.ansible_collection?
      keys += [:label, :content_type] if params[:action] == "create"
      if params[:action] == 'create' || @repository.custom?
        keys += [:url, :gpg_key_id, :ssl_ca_cert_id, :ssl_client_cert_id, :ssl_client_key_id, :unprotected, :name,
                 :checksum_type]
      end
      params.require(:repository).permit(*keys).to_h.with_indifferent_access
    end

    def check_ignore_global_proxy
      if params.key?(:ignore_global_proxy)
        ::Foreman::Deprecation.api_deprecation_warning("The parameter ignore_global_proxy will be removed in a future Katello release. Please update to use the http_proxy_policy parameter.")
        if ::Foreman::Cast.to_bool(params[:ignore_global_proxy])
          params[:repository][:http_proxy_policy] = RootRepository::NO_DEFAULT_HTTP_PROXY
        else
          params[:repository][:http_proxy_policy] = RootRepository::GLOBAL_DEFAULT_HTTP_PROXY
        end
      end
    end

    def get_content_credential(repo_params, content_type)
      credential_value = @product.send(content_type)

      unless repo_params["#{content_type}_id".to_sym].blank?
        credential_value = instance_variable_get("@#{content_type}")
      end

      credential_value
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def construct_repo_from_params(repo_params)
      root = @product.add_repo(repo_params.slice(:label, :name, :description, :url, :content_type, :arch, :unprotected,
                                                            :gpg_key, :ssl_ca_cert, :ssl_client_cert, :ssl_client_key,
                                                            :checksum_type, :download_policy, :http_proxy_policy).to_h.with_indifferent_access)
      root.docker_upstream_name = repo_params[:docker_upstream_name] if repo_params[:docker_upstream_name]
      root.docker_tags_whitelist = repo_params.fetch(:docker_tags_whitelist, []) if root.docker?
      root.mirror_on_sync = ::Foreman::Cast.to_bool(repo_params[:mirror_on_sync]) if repo_params.key?(:mirror_on_sync)
      root.verify_ssl_on_sync = ::Foreman::Cast.to_bool(repo_params[:verify_ssl_on_sync]) if repo_params.key?(:verify_ssl_on_sync)
      root.upstream_username = repo_params[:upstream_username] if repo_params.key?(:upstream_username)
      root.upstream_password = repo_params[:upstream_password] if repo_params.key?(:upstream_password)
      root.ignorable_content = repo_params[:ignorable_content] if root.yum? && repo_params.key?(:ignorable_content)
      root.ansible_collection_requirements = repo_params[:ansible_collection_requirements] if root.ansible_collection?
      root.http_proxy_policy = repo_params[:http_proxy_policy] if repo_params.key?(:http_proxy_policy)
      root.http_proxy_id = repo_params[:http_proxy_id] if repo_params.key?(:http_proxy_id)

      if root.ostree?
        root.ostree_upstream_sync_policy = repo_params[:ostree_upstream_sync_policy]
        root.ostree_upstream_sync_depth = repo_params[:ostree_upstream_sync_depth]
      end
      if root.deb?
        root.deb_releases = repo_params[:deb_releases] if repo_params[:deb_releases]
        root.deb_components = repo_params[:deb_components] if repo_params[:deb_components]
        root.deb_architectures = repo_params[:deb_architectures] if repo_params[:deb_architectures]
      end

      root
    end
    # rubocop:enable Metrics/CyclomaticComplexity

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
      if params[:content_type]
        @content = @repository.units_for_removal(params[:ids], params[:content_type])
      else
        @content = @repository.units_for_removal(params[:ids])
      end
    end

    def filter_by_content_view(query, content_view_id, environment_id, is_available_for)
      if is_available_for
        params[:library] = true
        sub_query = ContentViewRepository.where(:content_view_id => content_view_id).pluck(:repository_id)
        query = query.where("#{Repository.table_name}.id not in (#{sub_query.join(',')})") unless sub_query.empty?
      elsif environment_id
        version = ContentViewVersion.in_environment(environment_id).where(:content_view_id => content_view_id)
        query = query.where(:content_view_version_id => version)
      elsif params[:available_for] != 'content_view_version'
        query = query.joins(:content_view_repositories).where("#{ContentViewRepository.table_name}.content_view_id" => content_view_id)
      else
        version_ids = ContentViewVersion.where(:content_view_id => content_view_id).pluck(:id)
        query = query.where('content_view_version_id IN (?) AND environment_id IS NOT NULL', version_ids)
      end
      query
    end
  end
end
