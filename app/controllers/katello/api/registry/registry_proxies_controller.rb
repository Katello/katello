module Katello
  # rubocop:disable Metrics/ClassLength
  class Api::Registry::RegistryProxiesController < Api::V2::ApiController
    before_action :disable_strong_params
    before_action :confirm_settings
    before_action :confirm_push_settings, only: [:start_upload_blob, :upload_blob, :finish_upload_blob,
                                                 :chunk_upload_blob, :push_manifest]
    skip_before_action :authorize
    before_action :optional_authorize, only: [:token, :catalog]
    before_action :registry_authorize, except: [:token, :v1_search, :catalog]
    before_action :authorize_repository_read, only: [:pull_manifest, :tags_list]
    before_action :authorize_repository_write, only: [:push_manifest]
    skip_before_action :check_media_type, only: [:start_upload_blob, :upload_blob, :finish_upload_blob,
                                                 :chunk_upload_blob, :push_manifest]

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
        headers[header[0].split('_')[1..-1].join('-')] = header[1]
      end

      if (manifest_response = redirect_client { Resources::Registry::Proxy.get(@_request.fullpath, headers) })
        response.header['Docker-Content-Digest'] = manifest_response.headers[:docker_content_digest]
        response.headers['Content-Type'] = manifest_response.headers[:content_type]
        response.header['Content-Length'] = manifest_response.headers[:content_length]
        render json: manifest_response
      end
    end

    def check_blob
      begin
        r = Resources::Registry::Proxy.get(@_request.fullpath, 'Accept' => request.headers['Accept'])
        response.header['Content-Length'] = "#{r.body.size}"
      rescue RestClient::NotFound
        digest_file = tmp_file("#{params[:digest][7..-1]}.tar")
        raise unless File.exist? digest_file
        response.header['Content-Length'] = "#{File.size digest_file}"
      end
      render json: {}
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

    # FIXME: Reimplement for Pulp 3.
    def push_manifest
      repository = params[:repository]
      tag = params[:tag]

      manifest = create_manifest
      return if manifest.nil?

      begin
        files = get_manifest_files(repository, manifest)
        return if files.nil?

        tar_file = create_tar_file(files, repository, tag)
        return if tar_file.nil?

        digest = upload_manifest(tar_file)
        return if digest.nil?

        tag = upload_tag(digest, tag)
        return if tag.nil?
      ensure
        File.delete(tmp_file('manifest.json')) if File.exist? tmp_file('manifest.json')
      end

      render json: {}
    end

    # FIXME: This is referring to a non-existent Pulp 2 server.
    # Pulp 3 container push support is needed instead.
    def pulp_content
      Katello.pulp_server.resources.content
    end

    def start_upload_blob
      uuid = SecureRandom.hex(16)
      response.header['Location'] = "#{request_url}/v2/#{params[:repository]}/blobs/uploads/#{uuid}"
      response.header['Docker-Upload-UUID'] = uuid
      response.header['Range'] = '0-0'
      head 202
    end

    def status_upload_blob
      response.header['Location'] = "#{request_url}/v2/#{params[:repository]}/blobs/uploads/#{params[:uuid]}"
      response.header['Range'] = "123"
      response.header['Docker-Upload-UUID'] = "123"
      render plain: '', status: :no_content
    end

    def chunk_upload_blob
      response.header['Location'] = "#{request_url}/v2/#{params[:repository]}/blobs/uploads/#{params[:uuid]}"
      render plain: '', status: :accepted
    end

    def upload_blob
      File.open(tmp_file("#{params[:uuid]}.tar"), 'ab', 0600) do |file|
        file.write request.body.read
      end

      # ???? true chunked data?
      if request.headers['Content-Range']
        render_error 'unprocessable_entity', :status => :unprocessable_entity
      end

      response.header['Location'] = "#{request_url}/v2/#{params[:repository]}/blobs/uploads/#{params[:uuid]}"
      response.header['Range'] = "1-#{request.body.size}"
      response.header['Docker-Upload-UUID'] = params[:uuid]
      head 204
    end

    def finish_upload_blob
      # error by client if no params[:digest]

      uuid_file = tmp_file("#{params[:uuid]}.tar")
      digest_file = tmp_file("#{params[:digest][7..-1]}.tar")

      File.delete(digest_file) if File.exist? digest_file
      File.rename(uuid_file, digest_file)

      response.header['Location'] = "#{request_url}/v2/#{params[:repository]}/blobs/#{params[:digest]}"
      response.header['Docker-Content-Digest'] = params[:digest]
      response.header['Content-Range'] = "1-#{File.size(digest_file)}"
      response.header['Content-Length'] = "0"
      response.header['Docker-Upload-UUID'] = params[:uuid]
      head 201
    end

    def cancel_upload_blob
      render plain: '', status: :ok
    end

    def ping
      response.headers['Docker-Distribution-API-Version'] = 'registry/2.0'
      render json: {}, status: :ok
    end

    def v1_ping
      head 200
    end

    def v1_search
      # Checks for podman client and issues a 404 in that case. Podman
      # examines the response from a /v1_search request. If the result
      # is a 4XX, it will then proceed with a request to /_catalog
      if request.headers['HTTP_USER_AGENT'].downcase.include?('libpod')
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
      if manifest['schemaVersion'] == 1
        if manifest['fsLayers']
          files += manifest['fsLayers'].collect do |layer|
            layerfile = "#{layer['blobSum'][7..-1]}.tar"
            force_include_layer(repository, layer['blobSum'], layerfile)
            layerfile
          end
        end
      elsif manifest['schemaVersion'] == 2
        if manifest['layers']
          files += manifest['layers'].collect do |layer|
            layerfile = "#{layer['digest'][7..-1]}.tar"
            force_include_layer(repository, layer['digest'], layerfile)
            layerfile
          end
        end
        files << "#{manifest['config']['digest'][7..-1]}.tar"
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

    # FIXME: Reimplement for Pulp 3.
    def upload_manifest(tar_file)
      upload_id = pulp_content.create_upload_request['upload_id']
      filename = tmp_file(tar_file)
      uploads = []

      File.open(filename, 'rb') do |file|
        content = file.read
        pulp_content.upload_bits(upload_id, 0, content)

        uploads << {
          id: upload_id,
          name: filename,
          size: file.size,
          checksum: Digest::SHA256.hexdigest(content)
        }
      end

      File.delete(filename)
      task = sync_task(::Actions::Katello::Repository::ImportUpload,
                       @repository, uploads, generate_metadata: true, sync_capsule: true)
      task.output['upload_results'][0]['digest']
    ensure
      pulp_content.delete_upload_request(upload_id) if upload_id
    end

    # FIXME: Reimplement for Pulp 3.
    def upload_tag(digest, tag)
      upload_id = pulp_content.create_upload_request['upload_id']
      uploads = [{
        id: upload_id,
        name: tag,
        digest: digest
      }]
      sync_task(::Actions::Katello::Repository::ImportUpload, @repository, uploads,
                :generate_metadata => true, :sync_capsule => true)
      tag
    ensure
      pulp_content.delete_upload_request(upload_id) if upload_id
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
      render_error('custom_error', :status => :not_found,
                   :locals => { :message => "Registry push not supported" })
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

    def item_not_found(item)
      msg = "#{item} was not found!"
      # returning errors based on registry specifications in https://docs.docker.com/registry/spec/api/#errors
      render json: {errors: [code: :invalid_request, message: msg, details: msg]}, status: :not_found
    end
  end
end
