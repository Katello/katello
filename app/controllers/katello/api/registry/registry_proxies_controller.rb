module Katello
  class Api::Registry::RegistryProxiesController < Api::V2::ApiController
    before_action :disable_strong_params
    before_action :confirm_settings
    skip_before_action :authorize
    before_action :optional_authorize, only: [:token]
    before_action :registry_authorize, except: [:token]
    before_action :authorize_repository_read, only: [:pull_manifest, :tags_list]
    before_action :authorize_repository_write, only: [:push_manifest]
    skip_before_action :check_content_type, :only => [:start_upload_blob, :upload_blob, :finish_upload_blob,
                                                      :chunk_upload_blob, :push_manifest]
    skip_after_action :log_response_body, :only => [:pull_blob]

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

    def optional_authorize
      @repository = find_scope_repository
      if @repository && @repository.environment.registry_unauthenticated_pull
        true
      else
        authorize
      end
    end

    def registry_authorize
      @repository = find_readable_repository
      return true if request.method == 'GET' && @repository && @repository.environment.registry_unauthenticated_pull

      token = request.headers['Authorization']
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
          redirect_authorization_headers
          return false
        end
      end
      redirect_authorization_headers
      render_error('unauthorized', :status => :unauthorized)
      return false
    end

    def find_writable_repository
      Repository.docker_type.syncable.find_by_container_repository_name(params[:repository])
    end

    def authorize_repository_write
      @repository = find_writable_repository
      unless @repository
        not_found params[:repository]
        return false
      end
      true
    end

    # Reduce visible repos to include lifecycle env permissions
    # http://projects.theforeman.org/issues/22914
    def readable_repositories
      table_name = Repository.table_name
      in_products = Repository.where(:product_id => Katello::Product.authorized(:view_products)).select(:id)
      in_environments = Repository.where(:environment_id => Katello::KTEnvironment.authorized(:view_lifecycle_environments)).select(:id)
      in_content_views = Repository.joins(:content_view_repositories).where("#{ContentViewRepository.table_name}.content_view_id" => Katello::ContentView.readable).select(:id)
      in_versions = Repository.joins(:content_view_version).where("#{Katello::ContentViewVersion.table_name}.content_view_id" => Katello::ContentView.readable).select(:id)
      Repository.where("#{table_name}.id in (?) or #{table_name}.id in (?) or #{table_name}.id in (?) or #{table_name}.id in (?)", in_products, in_content_views, in_versions, in_environments)
    end

    def find_readable_repository
      return nil unless params[:repository]
      repository = Repository.docker_type.find_by_container_repository_name(params[:repository])
      if repository && !repository.environment.registry_unauthenticated_pull
        repository = readable_repositories.docker_type.find_by_container_repository_name(params[:repository])
      end
      repository
    end

    def authorize_repository_read
      @repository = find_readable_repository
      unless @repository
        not_found params[:repository]
        return false
      end

      if params[:tag]
        if params[:tag][0..6] == 'sha256:'
          manifest = Katello::DockerManifestList.where(digest: params[:tag]).first || Katello::DockerManifest.where(digest: params[:tag]).first
          not_found params[:tag] unless manifest
        else
          tag = DockerMetaTag.where(repository_id: @repository.id, name: params[:tag]).first
          not_found params[:tag] unless tag
        end
      end

      true
    end

    def token
      if @repository && @repository.environment.registry_unauthenticated_pull
        personal_token = OpenStruct.new(token: 'unauthenticated', issued_at: Time.now, expires_at: Time.now + 3)
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

      response.headers['Docker-Distribution-API-Version'] = 'registry/2.0'
      render json: { token: personal_token.token, expires_at: personal_token.expires_at, issued_at: personal_token.created_at }
    end

    def pull_manifest
      headers = {}
      env = request.env.select do |key, _value|
        key.match("^HTTP.*")
      end
      env.each do |header|
        headers[header[0].split('_')[1..-1].join('-')] = header[1]
      end

      r = Resources::Registry::Proxy.get(@_request.fullpath, headers)
      logger.debug r
      results = JSON.parse(r)

      response.header['Docker-Content-Digest'] = "sha256:#{Digest::SHA256.hexdigest(r)}"
      render json: r, content_type: results['mediaType']
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

    def pull_blob
      r = Resources::Registry::Proxy.get(@_request.fullpath, 'Accept' => request.headers['Accept'])
      render json: r
    end

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
      render plain: '', status: 204
    end

    def chunk_upload_blob
      response.header['Location'] = "#{request_url}/v2/#{params[:repository]}/blobs/uploads/#{params[:uuid]}"
      render plain: '', status: 202
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
      render plain: '', status: 200
    end

    def ping
      response.headers['Docker-Distribution-API-Version'] = 'registry/2.0'
      render json: {}, status: 200
    end

    def v1_ping
      head 200
    end

    def v1_search
      options = {
        resource_class: Katello::Repository
      }
      params[:per_page] = params[:n] || 25
      params[:search] = params[:q]
      search_results = scoped_search(readable_repositories.where(content_type: 'docker').distinct,
                                   :container_repository_name, :asc, options)
      results = {
        num_results: search_results[:subtotal],
        query: params[:search]
      }
      results[:results] = search_results[:results].collect do |repository|
        { name: repository[:container_repository_name], description: repository[:description] }
      end
      render json: results, status: 200
    end

    def catalog
      repositories = readable_repositories.where(content_type: 'docker').collect do |repository|
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

    def upload_manifest(tar_file)
      upload_id = pulp_content.create_upload_request['upload_id']
      filename = tmp_file(tar_file)
      File.open(filename, 'rb') do |file|
        pulp_content.upload_bits(upload_id, 0, file.read)

        file.rewind
        content = file.read
        unit_keys = [{
          name: filename,
          size: file.size,
          checksum: Digest::SHA256.hexdigest(content)
        }]
        unit_type_id = 'docker_manifest'
        task = sync_task(::Actions::Katello::Repository::ImportUpload,
                         @repository, [upload_id], :unit_type_id => unit_type_id,
                         :unit_keys => unit_keys,
                         :generate_metadata => true, :sync_capsule => true)
        digest = task.output['upload_results'][0]['digest']

        File.delete(filename)

        digest
      end
    ensure
      pulp_content.delete_upload_request(upload_id) if upload_id
    end

    def upload_tag(digest, tag)
      upload_id = pulp_content.create_upload_request['upload_id']
      unit_keys = [{
        name: tag,
        digest: digest
      }]
      unit_type_id = 'docker_tag'
      sync_task(::Actions::Katello::Repository::ImportUpload,
                       @repository, [upload_id], :unit_type_id => unit_type_id,
                       :unit_keys => unit_keys,
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
      scopes[2] == 'pull' ? Repository.docker_type.find_by_container_repository_name(scopes[1]) : nil
    end

    def disable_strong_params
      params.permit!
    end

    def confirm_settings
      return true if SETTINGS[:katello][:registry]
      render_error('custom_error', :status => :not_found,
                   :locals => { :message => "Registry not configured" })
      false
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
      Rails.logger.debug "With body: #{response.body}\n" unless route_name == 'pull_blob'
    end
  end
end
