module Katello
  class Api::V2::RepositoriesController < Api::V2::ApiController # rubocop:disable Metrics/ClassLength
    include Katello::Concerns::FilteredAutoCompleteSearch

    generic_repo_wrap_params = []
    RepositoryTypeManager.generic_remote_options(defined_only: true).each do |option|
      generic_repo_wrap_params << option.name
    end

    repo_wrap_params = RootRepository.attribute_names + generic_repo_wrap_params

    wrap_parameters :repository, :include => repo_wrap_params

    CONTENT_CREDENTIAL_GPG_KEY_TYPE = "gpg_key".freeze
    CONTENT_CREDENTIAL_SSL_CA_CERT_TYPE = "ssl_ca_cert".freeze
    CONTENT_CREDENTIAL_SSL_CLIENT_CERT_TYPE = "ssl_client_cert".freeze
    CONTENT_CREDENTIAL_SSL_CLIENT_KEY_TYPE = "ssl_client_key".freeze

    before_action :find_optional_organization, :only => [:index, :auto_complete_search]
    before_action :find_product, :only => [:index, :auto_complete_search]
    before_action :find_product_for_create, :only => [:create]
    before_action :find_organization_from_product, :only => [:create]
    before_action :find_unauthorized_katello_resource, :only => [:gpg_key_content]
    before_action :find_authorized_katello_resource, :only => [:show, :update, :destroy, :sync,
                                                               :remove_content, :upload_content, :republish,
                                                               :import_uploads, :verify_checksum, :reclaim_space]
    before_action :find_content, :only => :remove_content
    before_action :find_organization_from_repo, :only => [:update]
    before_action :error_on_rh_product, :only => [:create]
    before_action :check_import_parameters, :only => [:import_uploads]
    before_action(:only => [:create, :update]) { find_content_credential CONTENT_CREDENTIAL_GPG_KEY_TYPE }
    before_action(:only => [:create, :update]) { find_content_credential CONTENT_CREDENTIAL_SSL_CA_CERT_TYPE }
    before_action(:only => [:create, :update]) { find_content_credential CONTENT_CREDENTIAL_SSL_CLIENT_CERT_TYPE }
    before_action(:only => [:create, :update]) { find_content_credential CONTENT_CREDENTIAL_SSL_CLIENT_KEY_TYPE }
    skip_before_action :authorize, :only => [:gpg_key_content]
    skip_before_action :check_media_type, :only => [:upload_content]

    def custom_index_relation(collection)
      collection.includes(:product)
    end

    def_param_group :repo do
      param :url, String, :desc => N_("repository source url")
      param :os_versions, Array,
            :desc => N_("Identifies whether the repository should be disabled on a client with a non-matching OS version. Pass [] to enable regardless of OS version. Maximum length 1; allowed tags are: %s") % Katello::RootRepository::ALLOWED_OS_VERSIONS.join(', ')
      param :gpg_key_id, :number, :desc => N_("id of the gpg key that will be assigned to the new repository")
      param :ssl_ca_cert_id, :number, :desc => N_("Identifier of the content credential containing the SSL CA Cert")
      param :ssl_client_cert_id, :number, :desc => N_("Identifier of the content credential containing the SSL Client Cert")
      param :ssl_client_key_id, :number, :desc => N_("Identifier of the content credential containing the SSL Client Key")
      param :unprotected, :bool, :desc => N_("true if this repository can be published via HTTP")
      param :checksum_type, String, :desc => N_("Checksum of the repository, currently 'sha1' & 'sha256' are supported")
      param :docker_upstream_name, String, :desc => N_("Name of the upstream docker repository")
      param :docker_tags_whitelist, Array, :desc => N_("Comma-separated list of tags to sync for Container Image repository (Deprecated)"), :deprecated => true
      param :include_tags, Array, :desc => N_("Comma-separated list of tags to sync for a container image repository")
      param :exclude_tags, Array, :desc => N_("Comma-separated list of tags to exclude when syncing a container image repository. Default: any tag ending in \"-source\"")
      param :download_policy, ["immediate", "on_demand"], :desc => N_("download policy for yum, deb, and docker repos (either 'immediate' or 'on_demand')")
      param :download_concurrency, :number, :desc => N_("Used to determine download concurrency of the repository in pulp3. Use value less than 20. Defaults to 10")
      param :mirroring_policy, Katello::RootRepository::MIRRORING_POLICIES, :desc => N_("Policy to set for mirroring content.  Must be one of %s.") % RootRepository::MIRRORING_POLICIES
      param :verify_ssl_on_sync, :bool, :desc => N_("if true, Katello will verify the upstream url's SSL certifcates are signed by a trusted CA")
      param :upstream_username, String, :desc => N_("Username of the upstream repository user used for authentication")
      param :upstream_password, String, :desc => N_("Password of the upstream repository user used for authentication")
      param :upstream_authentication_token, String, :desc => N_("Password of the upstream authentication token.")
      param :deb_releases, String, :desc => N_("whitespace-separated list of releases to be synced from deb-archive")
      param :deb_components, String, :desc => N_("whitespace-separated list of repo components to be synced from deb-archive")
      param :deb_architectures, String, :desc => N_("whitespace-separated list of architectures to be synced from deb-archive")
      param :ignorable_content, Array, :desc => N_("List of content units to ignore while syncing a yum repository. Must be subset of %s") % RootRepository::IGNORABLE_CONTENT_UNIT_TYPES.join(",")
      param :ansible_collection_requirements, String, :desc => N_("Contents of requirement yaml file to sync from URL")
      param :ansible_collection_auth_url, String, :desc => N_("The URL to receive a session token from, e.g. used with Automation Hub.")
      param :ansible_collection_auth_token, String, :desc => N_("The token key to use for authentication.")
      param :http_proxy_policy, ::Katello::RootRepository::HTTP_PROXY_POLICIES, :desc => N_("policies for HTTP proxy for content sync")
      param :http_proxy_id, :number, :desc => N_("ID of a HTTP Proxy")
      param :arch, String, :desc => N_("Architecture of content in the repository")
      param :retain_package_versions_count, :number, :desc => N_("The maximum number of versions of each package to keep.")
      param :metadata_expire, :number, :desc => N_("Time to expire yum metadata in seconds. Only relevant for custom yum repositories.")
      RepositoryTypeManager.generic_remote_options(defined_only: true).each do |option|
        param option.name, option.type, :desc => N_(option.description)
      end
    end

    def_param_group :repo_create do
      param :label, String, :required => false
      param :product_id, :number, :required => true, :desc => N_("Product the repository belongs to")
      param :content_type, String, :required => true, :desc => N_("Type of repository. Available types endpoint: /katello/api/repositories/repository_types")
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
    param :library, :bool, :desc => N_("show repositories in Library and the default content view")
    param :archived, :bool, :desc => N_("show archived repositories")
    param :content_type, String, :desc => N_("Limit the repository type. Available types endpoint: /katello/api/repositories/repository_types")
    param :name, String, :desc => N_("name of the repository"), :required => false
    param :label, String, :desc => N_("label of the repository"), :required => false
    param :description, String, :desc => N_("description of the repository")
    param :available_for, String, :desc => N_("interpret specified object to return only Repositories that can be associated with specified object.  Only 'content_view' & 'content_view_version' are supported."),
          :required => false
    param :with_content, String, :desc => N_("Filter repositories by content unit type (erratum, docker_tag, etc.). Check the \"Indexed?\" types here: /katello/api/repositories/repository_types")
    param :download_policy, ::Katello::RootRepository::DOWNLOAD_POLICIES, :desc => N_("limit to only repositories with this download policy")
    param :username, String, :desc => N_("only show the repositories readable by this user with this username")
    param_group :search, Api::V2::ApiController
    add_scoped_search_description_for(Repository)
    def index
      unless params[:content_type].empty? || RepositoryTypeManager.find(params[:content_type])
        msg = _("Invalid params provided - content_type must be one of %s") %
          RepositoryTypeManager.enabled_repository_types.keys.sort.join(",")
        fail HttpErrors::UnprocessableEntity, msg
      end
      unless params[:with_content].empty? || RepositoryTypeManager.find_content_type(params[:with_content], true)
        msg = _("Invalid params provided - with_content must be one of %s") %
          RepositoryTypeManager.indexable_content_types.map(&:label).sort.join(",")
        fail HttpErrors::UnprocessableEntity, msg
      end
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
      query = query.joins(:root).where("#{RootRepository.table_name}.download_policy" => params[:download_policy]) if params[:download_policy]
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

      generic_type_param = RepositoryTypeManager.generic_content_types.find { |type| params["#{type}_id".to_sym] }
      if generic_type_param
        query = query.joins(:generic_content_units)
                     .where("#{GenericContentUnit.table_name}.id" => GenericContentUnit.with_identifiers(params["#{generic_type_param}_id".to_sym]))
      end

      query
    end

    api :GET, "/repositories/compare/", N_("List :resource")
    param :content_view_version_ids, Array, :desc => N_("content view versions to compare")
    param :repository_id, :number, :desc => N_("Library repository id to restrict comparisons to")
    param :restrict_comparison, String, :desc => N_("Return same, different or all results")

    def compare
      fail _("No content_view_version_ids provided") if params[:content_view_version_ids].empty?
      @versions = ContentViewVersion.readable.where(:id => params[:content_view_version_ids])
      if @versions.count != params[:content_view_version_ids].uniq.length
        missing = params[:content_view_version_ids] - @versions.pluck(:id)
        fail HttpErrors::NotFound, _("Couldn't find content view versions '%s'") % missing.join(',')
      end

      archived_version_repos = Katello::Repository.where(:content_view_version_id => @versions&.pluck(:id))&.archived
      repos = Katello::Repository.where(id: archived_version_repos&.pluck(:library_instance_id))
      repos = repos.where(:root_id => @repo.root_id) if @repo
      repositories = restrict_comparison(repos, @versions, params[:restrict_comparison])
      collection = scoped_search(repositories.distinct, :name, :asc)
      collection[:results] = collection[:results].map { |item| ContentViewVersionComparePresenter.new(item, @versions, @repo) }
      respond_for_index(:collection => collection)
    end

    def restrict_comparison(collection, content_view_versions = nil, compare = 'all')
      case compare
      when 'same'
        same_repo_ids = compare_same(collection, content_view_versions)
        collection.where(id: same_repo_ids)
      when 'different'
        same_repo_ids = compare_same(collection, content_view_versions)
        collection.where.not(id: same_repo_ids)
      else
        collection
      end
    end

    def compare_same(collection, content_view_versions = nil)
      same_repo_ids = []
      collection.each do |repo|
        if (content_view_versions&.pluck(:id)&.- repo.published_in_versions&.pluck(:id))&.empty?
          same_repo_ids << repo.id
        end
      end
      same_repo_ids
    end

    api :POST, "/repositories", N_("Create a custom repository")
    param :name, String, :desc => N_("Name of the repository"), :required => true
    param :description, String, :desc => N_("Description of the repository"), :required => false
    param_group :repo_create
    param_group :repo
    def create
      repo_params = repository_params
      unless RepositoryTypeManager.creatable_by_user?(repo_params[:content_type], false)
        msg = _("Invalid params provided - content_type must be one of %s") %
          RepositoryTypeManager.creatable_repository_types.keys.sort.join(",")
        fail HttpErrors::UnprocessableEntity, msg
      end

      if !repo_params[:url].nil? && URI(repo_params[:url]).userinfo
        fail "Do not include the username/password in the URL. Use the username/password settings instead."
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
      repo_types = creatable ? RepositoryTypeManager.creatable_repository_types : RepositoryTypeManager.enabled_repository_types
      render :json => repo_types.values
    end

    api :PUT, "/repositories/:id/republish", N_("Forces a republish of the specified repository, regenerating metadata and symlinks on the filesystem.")
    param :id, :number, :desc => N_("Repository identifier"), :required => true
    param :force, :bool, :desc => N_("Force metadata regeneration to proceed.  Dangerous when repositories use the 'Complete Mirroring' mirroring policy."), :required => true
    def republish
      unless ::Foreman::Cast.to_bool(params[:force])
        fail HttpErrors::BadRequest, _('Metadata republishing must be forced because it is a dangerous operation.')
      end
      task = async_task(::Actions::Katello::Repository::MetadataGenerate, @repository)
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
    param :skip_metadata_check, :bool, :desc => N_("Force sync even if no upstream changes are detected. Only used with yum or deb repositories."), :required => false
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

      task = async_task(::Actions::Katello::Repository::Sync, @repository, sync_options)
      respond_for_async :resource => task
    rescue Errors::InvalidActionOptionError => e
      raise HttpErrors::BadRequest, e.message
    end

    api :POST, "/repositories/:id/verify_checksum", N_("Verify checksum of repository contents")
    param :id, :number, :required => true, :desc => N_("repository ID")
    def verify_checksum
      task = async_task(::Actions::Katello::Repository::VerifyChecksum, @repository)
      respond_for_async :resource => task
    rescue Errors::InvalidActionOptionError => e
      raise HttpErrors::BadRequest, e.message
    end

    api :POST, "/repositories/:id/reclaim_space", N_("Reclaim space from an On Demand repository")
    param :id, :number, :required => true, :desc => N_("repository ID")
    def reclaim_space
      if @repository.download_policy != ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
        fail HttpErrors::BadRequest, _("Only On Demand repositories may have space reclaimed.")
      end
      task = async_task(::Actions::Pulp3::Repository::ReclaimSpace, @repository)
      respond_for_async :resource => task
    rescue Errors::InvalidActionOptionError => e
      raise HttpErrors::BadRequest, e.message
    end

    api :PUT, "/repositories/:id", N_("Update a repository")
    param :id, :number, :required => true, :desc => N_("repository ID")
    param :name, String, :required => false
    param :description, String, :desc => N_("description of the repository"), :required => false
    param_group :repo
    def update
      repo_params = repository_params
      if !repo_params[:url].nil? && URI(repo_params[:url]).userinfo
        fail "Do not include the username/password in the URL. Use the username/password settings instead."
      end

      if @repository.generic?
        generic_remote_options = generic_remote_options_hash(repo_params)
        repo_params[:generic_remote_options] = generic_remote_options.to_json
        RepositoryTypeManager.generic_remote_options.each do |option|
          repo_params&.delete(option.name)
        end
      end

      sync_task(::Actions::Katello::Repository::Update, @repository.root, repo_params)
      respond_for_show(:resource => @repository)
    end

    api :DELETE, "/repositories/:id", N_("Destroy a custom repository")
    param :id, :number, :required => true
    param :remove_from_content_view_versions, :bool, :required => false, :desc => N_("Force delete the repository by removing it from all content view versions")
    def destroy
      sync_task(::Actions::Katello::Repository::Destroy, @repository,
        remove_from_content_view_versions: ::Foreman::Cast.to_bool(params.fetch(:remove_from_content_view_versions, false)))
      respond_for_destroy
    end

    api :PUT, "/repositories/:id/remove_packages"
    api :PUT, "/repositories/:id/remove_docker_manifests"
    api :PUT, "/repositories/:id/remove_content"
    desc "Remove content from a repository"
    param :id, :number, :required => true, :desc => "repository ID"
    param 'ids', Array, :required => true, :desc => "Array of content ids to remove"
    param :content_type, String, :required => false, :desc => N_("The type of content to remove (srpm, docker_manifest, etc.). Check removable types here: /katello/api/repositories/repository_types")
    param 'sync_capsule', :bool, :desc => N_("Whether or not to sync an external capsule after upload. Default: true")
    def remove_content
      unless params[:content_type].empty? || RepositoryTypeManager.removable_content_types.map(&:label).include?(params[:content_type])
        msg = _("Invalid params provided - content_type must be one of %s") %
          RepositoryTypeManager.removable_content_types.map(&:label).sort.join(",")
        fail HttpErrors::UnprocessableEntity, msg
      end
      sync_capsule = ::Foreman::Cast.to_bool(params.fetch(:sync_capsule, true))
      fail _("No content ids provided") if @content.blank?
      respond_for_async :resource => sync_task(::Actions::Katello::Repository::RemoveContent, @repository, @content, content_type: params[:content_type], sync_capsule: sync_capsule)
    end

    api :POST, "/repositories/:id/upload_content", N_("Upload content into the repository")
    param :id, :number, :required => true, :desc => N_("repository ID")
    param :content, File, :required => true, :desc => N_("Content files to upload. Can be a single file or array of files.")
    param :content_type, String, :required => false, :desc => N_("The type of content to upload (srpm, file, etc.). Check uploadable types here: /katello/api/repositories/repository_types")
    def upload_content
      fail Katello::Errors::InvalidRepositoryContent, _("Cannot upload Container Image content.") if @repository.docker?
      fail Katello::Errors::InvalidRepositoryContent, _("Cannot upload Ansible collections.") if @repository.ansible_collection?
      unless params[:content_type].empty? || RepositoryTypeManager.uploadable_content_types.map(&:label).include?(params[:content_type])
        msg = _("Invalid params provided - content_type must be one of %s") %
          RepositoryTypeManager.uploadable_content_types.map(&:label).sort.join(",")
        fail HttpErrors::UnprocessableEntity, msg
      end

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
    param :content_type, RepositoryTypeManager.uploadable_content_types(false).map(&:label), :required => false, :desc => N_("content type ('deb', 'docker_manifest', 'file', 'ostree_ref', 'rpm', 'srpm')")
    param :uploads, Array, :desc => N_("Array of uploads to import") do
      param 'id', String, :required => true
      param 'content_unit_id', String
      param 'size', String
      param 'checksum', String
      param 'name', String, :desc => N_("Needs to only be set for file repositories or docker tags"), :required => true
      param 'digest', String, :desc => N_("Needs to only be set for docker tags")
    end
    Katello::RepositoryTypeManager.generic_repository_types.each_pair do |_, repo_type|
      repo_type.import_attributes.each do |import_attribute|
        param import_attribute.api_param, import_attribute.type,
            :desc => N_(import_attribute.description)
      end
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

      if @repository.content_type != 'docker' && uploads.first['checksum'].nil?
        fail HttpErrors::BadRequest, _('Checksum is a required parameter.')
      end

      if uploads.first['name'].nil?
        fail HttpErrors::BadRequest, _('Name is a required parameter.')
      end

      begin
        upload_args = {
          content_type: params[:content_type],
          generate_metadata: generate_metadata,
          sync_capsule: sync_capsule
        }
        upload_args.merge!(generic_content_type_import_upload_args)

        respond_for_async(resource: send(
          async ? :async_task : :sync_task,
          ::Actions::Katello::Repository::ImportUpload, @repository, uploads, upload_args))
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

    api :GET, "/content_types", N_("Return the enabled content types")
    def content_types
      render :json => Katello::RepositoryTypeManager.enabled_content_types.map { |type| Katello::RepositoryTypeManager.find_content_type(type) }
    end

    protected

    def find_product
      if params[:product_id]
        @product = Product.readable.find_by(id: params[:product_id])
        throw_resource_not_found(name: 'product', id: params[:product_id]) if @product.nil?
      end

      find_organization_from_product if @organization.nil? && @product
    end

    def find_product_for_create
      @product = Product.editable.find_by(id: params[:product_id])
      throw_resource_not_found(name: 'product', id: params[:product_id]) if @product.nil?
    end

    def find_content_credential(content_type)
      credential_id = "#{content_type}_id".to_sym
      credential_var = "@#{content_type}"

      if params[credential_id]
        credential_value = ContentCredential.readable.where(:id => params[credential_id], :organization_id => @organization).first
        instance_variable_set(credential_var, credential_value)
        if instance_variable_get(credential_var).nil?
          fail HttpErrors::NotFound, _("Couldn't find %{content_type} with id '%{id}'") % { :content_type => content_type, :id => params[credential_id] }
        end
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def repository_params
      keys = [:download_policy, :mirroring_policy, :sync_policy, :arch, :verify_ssl_on_sync, :upstream_password,
              :upstream_username, :download_concurrency, :upstream_authentication_token, :metadata_expire,
              {:os_versions => []}, :deb_releases, :deb_components, :deb_architectures, :description,
              :http_proxy_policy, :http_proxy_id, :retain_package_versions_count, {:ignorable_content => []}
             ]
      keys += [{:docker_tags_whitelist => []}, {:include_tags => []}, {:exclude_tags => []}, :docker_upstream_name] if params[:action] == 'create' || @repository&.docker?
      keys += [:ansible_collection_requirements, :ansible_collection_auth_url, :ansible_collection_auth_token] if params[:action] == 'create' || @repository&.ansible_collection?
      keys += [:label, :content_type] if params[:action] == "create"

      if params[:action] == 'create' || @repository&.generic?
        RepositoryTypeManager.generic_remote_options.each do |option|
          if option.type == Array
            keys += [{option.name => []}]
          elsif option.type == Hash
            keys += [{option.name => {}}]
          else
            keys += [option.name]
          end
        end
      end
      if params[:action] == 'create' || @repository.custom?
        keys += [:url, :gpg_key_id, :ssl_ca_cert_id, :ssl_client_cert_id, :ssl_client_key_id, :unprotected, :name,
                 :checksum_type]
      end
      params.require(:repository).permit(*keys).to_h.with_indifferent_access
    end

    def get_content_credential(repo_params, content_type)
      credential_value = @product.send(content_type)

      unless repo_params["#{content_type}_id".to_sym].blank?
        credential_value = instance_variable_get("@#{content_type}")
      end

      credential_value
    end

    # rubocop:disable Metrics/PerceivedComplexity,Metrics/MethodLength
    def construct_repo_from_params(repo_params) # rubocop:disable Metrics/AbcSize
      root = @product.add_repo(repo_params.slice(:label, :name, :description, :url, :content_type, :arch, :unprotected,
                                                            :gpg_key, :ssl_ca_cert, :ssl_client_cert, :ssl_client_key,
                                                            :checksum_type, :download_policy, :http_proxy_policy,
                                                            :metadata_expire).to_h.with_indifferent_access)
      root.docker_upstream_name = repo_params[:docker_upstream_name] if repo_params[:docker_upstream_name]
      if root.docker?
        if repo_params[:docker_tags_whitelist].present?
          root.include_tags = repo_params.fetch(:docker_tags_whitelist, [])
        else
          root.include_tags = repo_params.fetch(:include_tags, [])
        end
      end
      root.exclude_tags = repo_params.fetch(:exclude_tags, ['*-source']) if root.docker?
      root.verify_ssl_on_sync = ::Foreman::Cast.to_bool(repo_params[:verify_ssl_on_sync]) if repo_params.key?(:verify_ssl_on_sync)
      root.mirroring_policy = repo_params[:mirroring_policy] || Katello::RootRepository::MIRRORING_POLICY_CONTENT
      root.upstream_username = repo_params[:upstream_username] if repo_params.key?(:upstream_username)
      root.upstream_password = repo_params[:upstream_password] if repo_params.key?(:upstream_password)
      root.upstream_authentication_token = repo_params[:upstream_authentication_token] if repo_params.key?(:upstream_authentication_token)
      root.ignorable_content = repo_params[:ignorable_content] if root.yum? && repo_params.key?(:ignorable_content)
      root.http_proxy_policy = repo_params[:http_proxy_policy] if repo_params.key?(:http_proxy_policy)
      root.http_proxy_id = repo_params[:http_proxy_id] if repo_params.key?(:http_proxy_id)
      root.os_versions = repo_params.fetch(:os_versions, []) if root.yum?
      root.retain_package_versions_count = repo_params[:retain_package_versions_count] if root.yum? && repo_params.key?(:retain_package_versions_count)

      if root.generic?
        generic_remote_options = generic_remote_options_hash(repo_params)
        root.generic_remote_options = generic_remote_options.to_json
      end

      if root.deb?
        root.deb_releases = repo_params[:deb_releases] if repo_params[:deb_releases]
        root.deb_components = repo_params[:deb_components] if repo_params[:deb_components]
        root.deb_architectures = repo_params[:deb_architectures] if repo_params[:deb_architectures]
      end

      if root.ansible_collection?
        root.ansible_collection_requirements = repo_params[:ansible_collection_requirements] if repo_params[:ansible_collection_requirements]
        root.ansible_collection_auth_url = repo_params[:ansible_collection_auth_url] if repo_params[:ansible_collection_auth_url]
        root.ansible_collection_auth_token = repo_params[:ansible_collection_auth_token] if repo_params[:ansible_collection_auth_token]
      end

      root
    end
    # rubocop:enable Metrics/CyclomaticComplexity,Metrics/MethodLength

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
      content_type = params[:content_type]

      if content_type
        RepositoryTypeManager.check_content_matches_repo_type!(@repository, params[:content_type]) if params[:content_type]
        @content = @repository.units_for_removal(params[:ids], content_type)
      else
        @content = @repository.units_for_removal(params[:ids])
      end

      if @repository.generic?
        if content_type
          RepositoryTypeManager.check_content_matches_repo_type!(@repository, @content.first.content_type)
        else
          RepositoryTypeManager.check_content_matches_repo_type!(@repository, @repository.repository_type.default_managed_content_type.label)
        end
      else
        RepositoryTypeManager.check_content_matches_repo_type!(@repository, @content.first.class::CONTENT_TYPE)
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

    def generic_remote_options_hash(repo_params)
      content_type = @repository&.content_type || repo_params[:content_type]
      RepositoryTypeManager.generic_remote_options(content_type: content_type).to_h do |option|
        [option.name, repo_params[option.name].nil? ? option&.default : repo_params[option.name]]
      end
    end

    def generic_content_type_import_upload_args
      args = {}
      @repository.repository_type&.import_attributes&.collect do |import_attribute|
        if params[import_attribute.api_param]
          args[import_attribute.api_param] = params[import_attribute.api_param]
        end
      end
      args
    end

    def check_import_parameters
      @repository.repository_type&.import_attributes&.each do |import_attribute|
        if import_attribute.required && params[import_attribute.api_param].blank?
          fail HttpErrors::UnprocessableEntity, _('%s is required') % import_attribute.api_param
        end
      end
    end
  end
end
