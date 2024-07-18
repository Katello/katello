module Katello
  # rubocop:disable Metrics/ClassLength
  class Api::Registry::RegistryProxiesController < Api::V2::ApiController
    before_action :disable_strong_params
    before_action :confirm_settings
    skip_before_action :authorize
    before_action :optional_authorize, only: [:token, :catalog]
    before_action :registry_authorize, except: [:token, :v1_search, :catalog]
    before_action :authorize_repository_read, only: [:pull_manifest, :tags_list, :check_blob, :pull_blob]
    before_action :container_push_prop_validation, only: [:start_upload_blob, :upload_blob, :finish_upload_blob, :push_manifest]
    before_action :create_container_repo_if_needed, only: [:start_upload_blob, :upload_blob, :finish_upload_blob, :push_manifest]
    skip_before_action :check_media_type, only: [:start_upload_blob, :upload_blob, :finish_upload_blob,
                                                 :push_manifest]

    wrap_parameters false

    around_action :repackage_message

    def repackage_message
      yield
    ensure
      response.headers['Docker-Distribution-API-Version'] = 'registry/2.0'
    end

    rescue_from RestClient::Exception do |e|
      Rails.logger.error pp_exception(e)
      if request_from_katello_cli?
        render json: { errors: [e.http_body] }, status: e.http_code
      else
        render plain: e.http_body, status: e.http_code
      end
    end

    def redirect_authorization_headers
      response.headers['Docker-Distribution-API-Version'] = 'registry/2.0'
      response.headers['Www-Authenticate'] = "Bearer realm=\"#{request_url}/v2/token\"," \
                                             "service=\"#{request.host}\"," \
                                             "scope=\"repository:registry:pull,push\""
    end

    def set_user_by_token(token, redirect_on_failure = true)
      if token
        token_type, token = token.split
        if token_type == 'Bearer' && token
          personal_token = PersonalAccessToken.find_by_token(token)
          if personal_token && !personal_token.expired?
            User.current = User.unscoped.find(personal_token.user_id)
            return true if User.current
          end
        elsif token_type == 'Basic' && token
          return true if authorize
          redirect_authorization_headers if redirect_on_failure
          return false
        end
      end
      false
    end

    def optional_authorize
      @repository = find_scope_repository
      if @repository && (@repository.environment.registry_unauthenticated_pull || ssl_client_authorized?(@repository.organization.label))
        true
      elsif params['action'] == 'catalog'
        set_user_by_token(request.headers['Authorization'], false)
      elsif (params['action'] == 'token' && params['scope'].blank? && params['account'].blank?)
        true
      else
        authorize
      end
    end

    def registry_authorize
      @repository = find_readable_repository
      return true if ['GET', 'HEAD'].include?(request.method) && @repository && !require_user_authorization?

      is_user_set = set_user_by_token(request.headers['Authorization'])

      return true if is_user_set

      redirect_authorization_headers
      render_error('unauthorized', :status => :unauthorized)
      return false
    end

    def container_push_prop_validation(props = nil)
      # Handle validation and repo creation for container pushes before talking to pulp
      return false unless confirm_push_settings
      props = parse_blob_push_props if props.nil?
      return false unless check_blob_push_field_syntax(props)

      # validate input and find the org and product either using downcase label or id
      if props[:schema] == "label"
        return false unless check_blob_push_org_label(props)
        return false unless check_blob_push_product_label(props)
      else
        return false unless check_blob_push_org_id(props)
        return false unless check_blob_push_product_id(props)
      end

      return false unless check_blob_push_container(props)
      true
    end

    def parse_blob_push_props(path_string = nil)
      # path string should follow one of these formats:
      #   - /v2/{org_label}/{product_label}/{name}/blobs/uploads...
      #   - /v2/id/{org_id}/{product_id}/{name}/blobs/uploads...
      #   - /v2/{org_label}/{product_label}/{name}/manifests/...
      #   - /v2/id/{org_id}/{product_id}/{name}/manifests/...
      # inputs not matching format will return {valid_format: false}
      path_string = @_request.fullpath if path_string.nil?
      segments = path_string.split('/')

      if segments.length >= 7 && segments[0] == "" && segments[1] == "v2" &&
        segments[2] != "id" && (segments[5] == "blobs" || segments[5] == "manifests")

        return {
          valid_format: true,
          schema: "label",
          organization: segments[2],
          product: segments[3],
          name: segments[4]
        }
      elsif segments.length >= 8 && segments[0] == "" && segments[1] == "v2" &&
        segments[2] == "id" && (segments[6] == "blobs" || segments[6] == "manifests")

        return {
          valid_format: true,
          schema: "id",
          organization: segments[3],
          product: segments[4],
          name: segments[5]
        }
      else
        return {valid_format: false}
      end
    end

    def check_blob_push_field_syntax(props)
      # check basic url field syntax
      unless props[:valid_format]
        return render_podman_error(
          "NAME_INVALID",
          _("Invalid format. Container pushes should follow 'organization_label/product_label/name' OR 'id/organization_id/product_id/name' schema."),
          :bad_request
        )
      end
      return true
    end

    # rubocop:disable Metrics/MethodLength
    def check_blob_push_org_label(props)
      org_label = props[:organization]
      unless org_label.present? && org_label.length > 0
        return render_podman_error(
          "NAME_INVALID",
          _("Invalid format. Organization label cannot be blank."),
          :bad_request
        )
      end
      org = Organization.where("LOWER(label) = '#{org_label}'") # convert to lowercase
      # reject ambiguous orgs (possible due to lowercase conversion)
      if org.length > 1
        # Determine if the repo already exists in one of the possible products. If yes,
        # inform the user they need to destroy the existing repo and use the ID format
        unless props[:product].blank? || props[:name].blank?
          org.each do |o|
            products = get_matching_products_from_org(o, props[:product])
            products.each do |prod|
              root_repos = get_root_repo_from_product(prod, props[:name])
              unless root_repos.empty?
                return render_podman_error(
                  "NAME_INVALID",
                  _("Due to a change in your organizations, this container name has become "\
                    "ambiguous (org name '%{org_label}'). If you wish to continue using this "\
                    "container name, destroy the organization in conflict with '%{o_name} (id "\
                    "%{o_id}). If you wish to keep both orgs, destroy '%{o_label}/%{prod_label}/"\
                    "%{root_repo_label}' and retry your push using the id format.") %
                      { org_label: org_label, o_name: o.name, o_id: o.id, o_label: o.label, prod_label: prod.label, root_repo_label: root_repos.first.label },
                  :conflict
                )
              end
            end
          end
        end

        # Otherwise tell them to try pushing with ID format
        return render_podman_error(
          "NAME_INVALID",
          _("Organization label '%s' is ambiguous. Try using an id-based container name.") % org_label,
          :conflict
        )
      end
      if org.length == 0
        return render_podman_error(
          "NAME_UNKNOWN",
          _("Organization not found: '%s'") % org_label,
          :not_found
        )
      end
      @organization = org.first
      true
    end

    def check_blob_push_org_id(props)
      org_id = props[:organization]
      unless org_id.present? && org_id == org_id.to_i.to_s
        return render_podman_error(
          "NAME_INVALID",
          _("Invalid format. Organization id must be an integer without leading zeros."),
          :bad_request
        )
      end
      @organization = Organization.find_by_id(org_id.to_i)
      if @organization.nil?
        return render_podman_error(
          "NAME_UNKNOWN",
          _("Organization id not found: '%s'") % org_id,
          :not_found
        )
      end
      true
    end

    def check_blob_push_product_label(props)
      prod_label = props[:product]
      unless prod_label.present? && prod_label.length > 0
        return render_podman_error(
          "NAME_INVALID",
          _("Invalid format. Product label cannot be blank."),
          :bad_request
        )
      end
      product = get_matching_products_from_org(@organization, prod_label)
      # reject ambiguous products (possible due to lowercase conversion)
      if product.length > 1
        # Determine if the repo already exists in one of the possible products. If yes,
        # inform the user they need to destroy the existing repo and use the ID format
        unless props[:name].blank?
          product.each do |prod|
            root_repos = get_root_repo_from_product(prod, props[:name])
            unless root_repos.empty?
              return render_podman_error(
                "NAME_INVALID",
                _("Due to a change in your products, this container name has become ambiguous "\
                  "(product name '%{prod_label}'). If you wish to continue using this container "\
                  "name, destroy the product in conflict with '%{prod_name}' (id %{prod_id}). If "\
                  "you wish to keep both products, destroy '%{org_label}/%{prod_dot_label}/"\
                  "%{root_repo_label}' and retry your push using the id format.") %
                    { prod_label: prod_label, prod_name: prod.name, prod_id: prod.id, org_label: @organization.label, prod_dot_label: prod.label, root_repo_label: root_repos.first.label },
                :conflict
              )
            end
          end
        end

        return render_podman_error(
          "NAME_INVALID",
          _("Product label '%s' is ambiguous. Try using an id-based container name.") % prod_label,
          :conflict
        )
      end
      if product.length == 0
        return render_podman_error(
          "NAME_UNKNOWN",
          _("Product not found: '%s'") % prod_label,
          :not_found
        )
      end
      @product = product.first
      true
    end

    def check_blob_push_product_id(props)
      prod_id = props[:product]
      unless prod_id.present? && prod_id == prod_id.to_i.to_s
        return render_podman_error(
          "NAME_INVALID",
          _("Invalid format. Product id must be an integer without leading zeros."),
          :bad_request
        )
      end
      @product = @organization.products.find_by_id(prod_id.to_i)
      if @product.nil?
        return render_podman_error(
          "NAME_UNKNOWN",
          _("Product id not found: '%s'") % prod_id,
          :not_found
        )
      end
      true
    end

    def get_matching_products_from_org(organization, product_label)
      return organization.products.where("LOWER(label) = '#{product_label}'") # convert to lowercase
    end

    def get_root_repo_from_product(product, root_repo_name)
      return product.root_repositories.where(label: root_repo_name)
    end

    def root_repository
      @root_repository ||= get_root_repo_from_product(@product, @container_name)&.first
      @root_repository
    end

    def check_blob_push_container(props)
      unless props[:name].present? && props[:name].length > 0
        return render_podman_error(
          "NAME_INVALID",
          _("Invalid format. Container name cannot be blank."),
          :bad_request
        )
      end

      @container_name = props[:name]
      @container_push_name_format = props[:schema]
      if @container_push_name_format == "label"
        @container_path_input = "#{props[:organization]}/#{props[:product]}/#{props[:name]}"
      else
        @container_path_input = "id/#{props[:organization]}/#{props[:product]}/#{props[:name]}"
      end

      # If the repo already exists, check if the existing push format matches
      root_repo = get_root_repo_from_product(@product, @container_name).first
      if !root_repo.nil? && @container_push_name_format != root_repo.container_push_name_format
        return render_podman_error(
          "NAME_INVALID",
          _("Repository name '%{container_name}' already exists in this product using a different naming scheme. Please retry your request with the %{root_repo_container_push_name} format or destroy and recreate the repository using your preferred schema.") %
            {container_name: @container_name, root_repo_container_push_name: root_repo.container_push_name_format},
          :conflict
        )
      end

      true
    end

    def create_container_repo_if_needed
      unless @product.syncable?
        return render_podman_error(
          'DENIED',
          _("Requested access to '%s' is denied") % @container_name,
          :not_found
        )
      end

      if get_root_repo_from_product(@product, @container_name).empty?
        root = @product.add_repo(
          name: @container_name,
          label: @container_name,
          download_policy: 'immediate',
          content_type: Repository::DOCKER_TYPE,
          unprotected: true,
          is_container_push: true,
          container_push_name: @container_path_input,
          container_push_name_format: @container_push_name_format
        )
        sync_task(::Actions::Katello::Repository::CreateRoot, root, @container_path_input)
      end
    end

    def save_pulp_push_repository_href
      instance_repo = root_repository&.library_instance

      unless root_repository.present? && instance_repo.present?
        return render_podman_error(
          "BLOB_UPLOAD_UNKNOWN",
          _("Could not locate local uploaded repository for content indexing."),
          :not_found
        )
      end

      pulp_api = instance_repo.backend_service(SmartProxy.pulp_primary).api
      push_repo_api_response = pulp_api.container_push_repo_for_name(@container_path_input)

      latest_version_href = push_repo_api_response&.latest_version_href
      pulp_repo_href = push_repo_api_response&.pulp_href

      if latest_version_href.empty? || pulp_repo_href.empty?
        return render_podman_error(
          "BLOB_UPLOAD_UNKNOWN",
          _("Could not locate repository properties for content indexing."),
          :not_found
        )
      end
      instance_repo.update!(version_href: latest_version_href)
      # The Pulp repository should not change after first creation
      if root_repository.repository_references.empty?
        ::Katello::Pulp3::RepositoryReference.where(root_repository_id: instance_repo.root_id,
                                                    content_view_id: instance_repo.content_view.id,
                                                    repository_href: pulp_repo_href).create!
      end
      return pulp_repo_href
    end

    def save_pulp_push_distribution_href(pulp_repo_href)
      instance_repo = root_repository&.library_instance
      pulp_api = instance_repo.backend_service(SmartProxy.pulp_primary).api
      instance_repo = root_repository&.library_instance
      distribution_api_response = pulp_api.container_push_distribution_for_repository(pulp_repo_href)
      pulp_distribution_href = distribution_api_response&.pulp_href

      if pulp_distribution_href.empty?
        return render_podman_error(
          "BLOB_UPLOAD_UNKNOWN",
          _("Could not locate Pulp distribution."),
          :not_found
        )
      end
      dist = ::Katello::Pulp3::DistributionReference.where(path: @container_path_input,
                                                           href: pulp_distribution_href,
                                                           repository_id: instance_repo.id).first
      if dist
        if dist.href != pulp_distribution_href
          dist.update(href: pulp_distribution_href)
        end
      else
        ::Katello::Pulp3::DistributionReference.create!(path: @container_path_input,
                                                       href: pulp_distribution_href,
                                                       repository_id: instance_repo.id)
      end
    end

    def save_push_repo_hrefs
      # After content upload, save Pulp hrefs.
      pulp_repo_href = save_pulp_push_repository_href
      return unless pulp_repo_href
      save_pulp_push_distribution_href(pulp_repo_href)
    end

    def find_writable_repository
      Repository.docker_type.syncable.find_by_container_repository_name(params[:repository])
    end

    def authorize_repository_write
      @repository = find_writable_repository
      return item_not_found(params[:repository]) unless @repository
      true
    end

    def find_readable_repository
      return nil unless params[:repository]
      repository = Repository.docker_type.find_by(container_repository_name: params[:repository])
      if require_user_authorization?(repository)
        repository = Repository.readable_docker_catalog.find_by(container_repository_name: params[:repository])
      end
      repository
    end

    def require_user_authorization?(repository = @repository)
      !(params['action'] == 'token' && params['scope'].blank? && params['account'].blank?) &&
        (!repository ||
          (!repository.archive? &&
            !repository.environment.registry_unauthenticated_pull &&
            !ssl_client_authorized?(repository.organization.label)))
    end

    def ssl_client_authorized?(org_label)
      request.headers['HTTP_SSL_CLIENT_VERIFY'] == "SUCCESS" && request.headers['HTTP_SSL_CLIENT_S_DN'] == "O=#{org_label}"
    end

    def authorize_repository_read
      @repository = find_readable_repository
      return item_not_found(params[:repository]) unless @repository

      if params[:tag]
        if params[:tag][0..6] == 'sha256:'
          manifest = Katello::DockerManifestList.where(digest: params[:tag]).first || Katello::DockerManifest.where(digest: params[:tag]).first
          return item_not_found(params[:tag]) unless manifest
        else
          tag = ::Katello::DockerMetaTag.where(id: ::Katello::RepositoryDockerMetaTag.
                                    where(repository_id: @repository.id).select(:docker_meta_tag_id), name: params[:tag]).first
          return item_not_found(params[:tag]) unless tag
        end
      end

      true
    end

    def token
      if !require_user_authorization?
        personal_token = OpenStruct.new(token: 'unauthenticated', issued_at: Time.now, expires_at: 3.minutes.from_now)
      else
        personal_token = PersonalAccessToken.where(user_id: User.current.id, name: 'registry').first
        if personal_token.nil?
          personal_token = PersonalAccessToken.new(user: User.current, name: 'registry', expires_at: 6.minutes.from_now)
          personal_token.generate_token
          personal_token.save!
        else
          personal_token.expires_at = 6.minutes.from_now
          personal_token.save!
        end
      end

      create_time = (personal_token.created_at || personal_token.issued_at).to_time
      expiry_time = personal_token.expires_at.to_time
      expiration_seconds = (expiry_time - create_time).to_int # result already in seconds

      response.headers['Docker-Distribution-API-Version'] = 'registry/2.0'
      render json: {
        token: personal_token.token,
        expires_in: expiration_seconds,
        issued_at: create_time.rfc3339,

        # We're keeping the 'expires_at' field for now to maintain compatibility with existing
        # smart-proxies during 4.11 upgrades. This is not a part of OAuth2 spec.
        # TODO - Remove 'expires_at' in Katello 4.13 or later.
        expires_at: expiry_time.rfc3339
      }
    end

    def pull_manifest
      headers = {}
      env = request.env.select do |key, _value|
        key.match("^HTTP_.*")
      end
      env.each do |header|
        headers[header[0].split('_')[1..].join('-')] = header[1]
      end

      if (manifest_response = redirect_client { Resources::Registry::Proxy.get(@_request.fullpath, headers) })
        response.header['Docker-Content-Digest'] = manifest_response.headers[:docker_content_digest]
        response.headers['Content-Type'] = manifest_response.headers[:content_type]
        response.header['Content-Length'] = manifest_response.headers[:content_length]
        render json: manifest_response
      end
    end

    def check_blob
      pulp_response = Resources::Registry::Proxy.get(@_request.fullpath, 'Accept' => request.headers['Accept'])
      head pulp_response.code
    end

    def redirect_client
      return yield
    rescue RestClient::Exception => exception
      if [301, 302, 307].include?(exception.response.code)
        redirect_to exception.response.headers[:location]
        nil
      else
        raise exception
      end
    end

    def pull_blob
      headers = {}
      headers['Accept'] = request.headers['Accept'] if request.headers['Accept']
      redirect_client { Resources::Registry::Proxy.get(@_request.fullpath, headers, max_redirects: 0) }
    end

    def translated_headers_for_proxy
      current_headers = {}
      env = request.env.select do |key, _value|
        key.match("^HTTP_.*")
      end
      env.each do |header|
        current_headers[header[0].split('_')[1..].join('-')] = header[1]
      end
      current_headers
    end

    def start_upload_blob
      headers = translated_headers_for_proxy
      headers['Content-Type'] = request.headers['Content-Type'] if request.headers['Content-Type']
      headers['Content-Length'] = request.headers['Content-Length'] if request.headers['Content-Length']
      pulp_response = Resources::Registry::Proxy.post(@_request.fullpath, @_request.body, headers)

      pulp_response.headers.each do |key, value|
        response.header[key.to_s] = value
      end

      save_push_repo_hrefs if pulp_response.code.between?(200, 299)
      head pulp_response.code
    end

    def upload_blob
      headers = translated_headers_for_proxy
      headers['Content-Type'] = request.headers['Content-Type'] if request.headers['Content-Type']
      headers['Content-Range'] = request.headers['Content-Range'] if request.headers['Content-Range']
      headers['Content-Length'] = request.headers['Content-Length'] if request.headers['Content-Length']
      body = @_request.body.read
      pulp_response = Resources::Registry::Proxy.patch(@_request.fullpath, body, headers)

      pulp_response.headers.each do |key, value|
        response.header[key.to_s] = value
      end

      save_push_repo_hrefs if pulp_response.code.between?(200, 299)
      head pulp_response.code
    end

    def finish_upload_blob
      headers = translated_headers_for_proxy
      headers['Content-Type'] = request.headers['Content-Type'] if request.headers['Content-Type']
      headers['Content-Range'] = request.headers['Content-Range'] if request.headers['Content-Range']
      headers['Content-Length'] = request.headers['Content-Length'] if request.headers['Content-Length']
      pulp_response = Resources::Registry::Proxy.put(@_request.fullpath, @_request.body, headers)

      pulp_response.headers.each do |key, value|
        response.header[key.to_s] = value
      end

      save_push_repo_hrefs if pulp_response.code.between?(200, 299)
      head pulp_response.code
    end

    def push_manifest
      headers = translated_headers_for_proxy
      headers['Content-Type'] = request.headers['Content-Type'] if request.headers['Content-Type']
      body = @_request.body.read
      pulp_response = Resources::Registry::Proxy.put(@_request.fullpath, body, headers)
      pulp_response.headers.each do |key, value|
        response.header[key.to_s] = value
      end

      save_push_repo_hrefs if pulp_response.code.between?(200, 299)
      # Indexing content is only needed after pushing manifests
      root_repository.library_instance.index_content
      head pulp_response.code
    end

    def ping
      response.headers['Docker-Distribution-API-Version'] = 'registry/2.0'
      render json: {}, status: :ok
    end

    def v1_ping
      head :ok
    end

    def v1_search
      # Checks for v2 client and issues a 404 in that case. Podman
      # examines the response from a /v1_search request. If the result
      # is a 4XX, it will then proceed with a request to /_catalog
      if request.headers['HTTP_DOCKER_DISTRIBUTION_API_VERSION'] == 'registry/2.0'
        render json: {}, status: :not_found
        return
      end

      authenticate # to set current_user, not to enforce
      options = {
        resource_class: Katello::Repository
      }
      params[:per_page] = params[:n] || 25
      params[:search] = params[:q]

      search_results = scoped_search(Repository.readable_docker_catalog.distinct,
                                     :container_repository_name, :asc, options)

      results = {
        num_results: search_results[:subtotal],
        query: params[:search]
      }
      results[:results] = search_results[:results].collect do |repository|
        { name: repository[:container_repository_name], description: repository[:description] }
      end
      render json: results, status: :ok
    end

    def catalog
      repositories = Repository.readable_docker_catalog.collect do |repository|
        repository.container_repository_name
      end
      render json: { repositories: repositories }
    end

    def tags_list
      tags = @repository.docker_tags.collect do |tag|
        tag.name
      end
      tags.uniq!
      tags.sort!
      render json: {
        name: @repository.container_repository_name,
        tags: tags
      }
    end

    def create_manifest
      filename = tmp_file('manifest.json')
      if File.exist? filename
        render_error('custom_error', :status => :unprocessable_entity,
                     :locals => { :message => "Upload already in progress" })
        return nil
      end
      manifest = request.body.read
      File.open(tmp_file('manifest.json'), 'wb', 0600) do |file|
        file.write manifest
      end
      manifest = JSON.parse(manifest)
    rescue
      File.delete(tmp_file('manifest.json')) if File.exist? tmp_file('manifest.json')
    end

    def get_manifest_files(repository, manifest)
      files = ['manifest.json']
      case manifest['schemaVersion']
      when 1
        if manifest['fsLayers']
          files += manifest['fsLayers'].collect do |layer|
            layerfile = "#{layer['blobSum'][7..]}.tar"
            force_include_layer(repository, layer['blobSum'], layerfile)
            layerfile
          end
        end
      when 2
        if manifest['layers']
          files += manifest['layers'].collect do |layer|
            layerfile = "#{layer['digest'][7..]}.tar"
            force_include_layer(repository, layer['digest'], layerfile)
            layerfile
          end
        end
        files << "#{manifest['config']['digest'][7..]}.tar"
      else
        render_error 'custom_error', :status => :internal_server_error,
                             :locals => { :message => "Unsupported schema #{manifest['schemaVersion']}" }
        return nil
      end
      files
    end

    def create_tar_file(files, repository, tag)
      tar_file = "#{repository}_#{tag}.tar"
      `/usr/bin/tar cf #{tmp_file(tar_file)} -C #{tmp_dir} #{files.join(' ')}`

      files.each do |file|
        filename = tmp_file(file)
        File.delete(filename) if File.exist? filename
      end
      tar_file
    end

    def tmp_dir
      "#{Rails.root}/tmp"
    end

    def tmp_file(filename)
      File.join(tmp_dir, filename)
    end

    # TODO: Until pulp supports optional upload of layers, include all layers
    # https://pulp.plan.io/issues/3497
    def force_include_layer(repository, digest, layer)
      unless File.exist? tmp_file(layer)
        logger.debug "Getting blob #{digest} to write to #{layer}"
        fullpath = "/v2/#{repository}/blobs/#{digest}"
        request = Resources::Registry::Proxy.get(fullpath)
        File.open(tmp_file(layer), 'wb', 0600) do |file|
          file.write request.body
        end
        logger.debug "Wrote blob #{digest} to #{layer}"
      end
    end

    def find_scope_repository
      scope = params['scope']
      return nil unless scope

      scopes = scope.split(':')
      scopes[2] == 'pull' ? Repository.docker_type.non_archived.find_by_container_repository_name(scopes[1]) : nil
    end

    def disable_strong_params
      params.permit!
    end

    def confirm_settings
      if SETTINGS.dig(:katello, :container_image_registry) || SmartProxy.pulp_primary&.pulp3_repository_type_support?(::Katello::Repository::DOCKER_TYPE)
        return true
      end
      render_error('custom_error', :status => :not_found,
                   :locals => { :message => "Registry not configured" })
    end

    def confirm_push_settings
      return true if SETTINGS.dig(:katello, :container_image_registry, :allow_push)
      render_podman_error(
        "UNSUPPORTED",
        _("Registry push is not enabled. To enable, add ':katello:'->':container_image_registry:'->':allow_push: true' in the katello settings file."),
        :unprocessable_entity
      )
    end

    def request_url
      request.protocol + request.host_with_port
    end

    def logger
      ::Foreman::Logging.logger('katello/registry_proxy')
    end

    def route_name
      Engine.routes.router.recognize(request) do |_, params|
        break params[:action] if params[:action]
      end
    end

    def process_action(method_name, *args)
      ::Api::V2::BaseController.instance_method(:process_action).bind(self).call(method_name, *args)
      Rails.logger.debug "With body: #{filter_sensitive_data(response.body)}\n" unless route_name == 'pull_blob'
    end

    def render_podman_error(code, message, status = :bad_request)
      # Renders a podman-compatible error and returns false.
      #     code: uppercase string code from opencontainer error code spec:
      #         https://specs.opencontainers.org/distribution-spec/?v=v1.0.0#DISTRIBUTION-SPEC-140
      #     message: a custom error string
      #     status: a symbol in the 400 block of the rails response code table:
      #         https://guides.rubyonrails.org/layouts_and_rendering.html#the-status-option
      render json: {errors: [{code: code, message: message}]}, status: status
      false
    end

    def item_not_found(item)
      render_podman_error("NAME_UNKNOWN", _("%s was not found!") % item, :not_found)
    end
  end
end
