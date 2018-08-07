require "katello_test_helper"

module Katello
  #rubocop:disable Metrics/BlockLength
  describe Api::Registry::RegistryProxiesController do
    include Support::ForemanTasks::Task

    def setup_models
      @docker_repo = katello_repositories(:busybox)
      @organization = @docker_repo.product.organization
      @docker_env_repo = katello_repositories(:busybox_view1)
      @rpm_repo = katello_repositories(:fedora_17_x86_64)
      @tag = katello_docker_tags(:one)
    end

    def setup_permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products
    end

    before do
      setup_models
      setup_permissions
      setup_controller_defaults_api

      SETTINGS[:katello][:container_image_registry] = {crane_url: 'https://localhost:5000', crane_ca_cert_file: '/etc/pki/katello/certs/katello-default-ca.crt'}

      File.delete("#{Rails.root}/tmp/manifest.json") if File.exist?("#{Rails.root}/tmp/manifest.json")
    end

    describe "registry config" do
      it "ping - unconfigured" do
        SETTINGS[:katello].except!(:container_image_registry)
        response = get :ping
        body = JSON.parse(response.body)
        assert_response 404
        assert_equal('Registry not configured', body['error']['message'])
      end
    end

    describe "docker login" do
      it "ping - unauthorized" do
        User.current = nil
        session[:user] = nil
        reset_api_credentials

        get :ping
        assert_response 401
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        assert_equal "Bearer realm=\"http://test.host/v2/token\"," \
                     "service=\"test.host\"," \
                     "scope=\"repository:registry:pull,push\"",
                     response.headers['Www-Authenticate']
      end

      it "ping - basic unauthorized" do
        User.current = nil
        session[:user] = nil
        reset_api_credentials

        get :ping
        assert_response 401
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        assert_equal "Bearer realm=\"http://test.host/v2/token\"," \
                     "service=\"test.host\"," \
                     "scope=\"repository:registry:pull,push\"",
                     response.headers['Www-Authenticate']
      end

      it "ping - bearer bad token" do
        User.current = nil
        session[:user] = nil
        @request.env['HTTP_AUTHORIZATION'] = "Bearer 12345"

        get :ping
        assert_response 401
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        assert_equal "Bearer realm=\"http://test.host/v2/token\"," \
                     "service=\"test.host\"," \
                     "scope=\"repository:registry:pull,push\"",
                     response.headers['Www-Authenticate']
      end

      it "ping - bearer expired" do
        User.current = nil
        session[:user] = nil
        @request.env['HTTP_AUTHORIZATION'] = "Bearer 12345"

        token = mock('token')
        token.stubs('expired?').returns(true)
        PersonalAccessToken.expects(:find_by_token).with("12345").returns(token)

        get :ping
        assert_response 401
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        assert_equal "Bearer realm=\"http://test.host/v2/token\"," \
                     "service=\"test.host\"," \
                     "scope=\"repository:registry:pull,push\"",
                     response.headers['Www-Authenticate']
      end

      it "ping - bearer authorized" do
        user = User.current
        User.current = nil
        session[:user] = nil
        @request.env['HTTP_AUTHORIZATION'] = "Bearer 12345"

        token = mock('token')
        token.stubs('expired?').returns(false)
        token.stubs(:user_id).returns(user.id)
        PersonalAccessToken.expects(:find_by_token).with("12345").returns(token)

        get :ping
        assert_response 200
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        assert_nil response.headers['Www-Authenticate']
      end

      it "ping - basic authorized" do
        get :ping
        assert_response 200
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        assert_nil response.headers['Www-Authenticate']
      end

      it "token - no 'registry' token yet" do
        PersonalAccessToken.expects(:where)
                           .with(user_id: User.current.id, name: 'registry')
                           .returns([])
        expiration = Time.now
        token = mock('token')
        token.stubs(:token).returns("12345")
        token.stubs(:generate_token).returns("12345")
        token.stubs(:user_id).returns(User.current.id)
        token.stubs(:expires_at).returns("#{expiration}")
        token.stubs(:created_at).returns("#{expiration}")
        token.stubs('save!').returns(true)
        PersonalAccessToken.expects(:new).returns(token)

        get :token
        assert_response 200
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        body = JSON.parse(response.body)
        assert_equal "12345", body['token']
        assert_equal "#{expiration}", body['expires_at']
        assert_equal "#{expiration}", body['issued_at']
      end

      it "token - has 'registry' token" do
        expiration = Time.now
        token = mock('token')
        token.stubs(:token).returns("12345")
        token.stubs(:generate_token).returns("12345")
        token.stubs(:user_id).returns(User.current.id)
        token.stubs(:expires_at).returns("#{expiration}")
        token.stubs(:created_at).returns("#{expiration}")
        token.stubs('save!').returns(true)
        token.expects('expires_at=').returns(true)
        PersonalAccessToken.expects(:where)
                           .with(user_id: User.current.id, name: 'registry')
                           .returns([token])
        PersonalAccessToken.expects(:new).never

        get :token
        assert_response 200
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        body = JSON.parse(response.body)
        assert_equal "12345", body['token']
        assert_equal "#{expiration}", body['expires_at']
        assert_equal "#{expiration}", body['issued_at']
      end

      it "token - unscoped is unauthorized" do
        User.current = nil
        session[:user] = nil
        reset_api_credentials

        get :token
        assert_response 401
      end

      it "token - allow unauthenticated pull" do
        @docker_repo.set_container_repository_name
        @docker_repo.save!
        @docker_repo.environment.registry_unauthenticated_pull = true
        @docker_repo.environment.save!

        User.current = nil
        session[:user] = nil
        reset_api_credentials

        get :token, params: { scope: "repository:#{@docker_repo.container_repository_name}:pull" }
        assert_response 200
      end

      it "token - do not allow unauthenticated pull" do
        @docker_repo.set_container_repository_name
        @docker_repo.save!
        @docker_repo.environment.registry_unauthenticated_pull = false
        @docker_repo.environment.save!

        User.current = nil
        session[:user] = nil
        reset_api_credentials

        get :token, params: { scope: "repository:#{@docker_repo.container_repository_name}:pull" }
        assert_response 401
      end

      it "token - do not allow unauthenticated push" do
        @docker_repo.set_container_repository_name
        @docker_repo.save!
        @docker_repo.environment.registry_unauthenticated_pull = true
        @docker_repo.environment.save!

        User.current = nil
        session[:user] = nil
        reset_api_credentials

        get :token, params: { scope: "repository:#{@docker_repo.container_repository_name}:push" }
        assert_response 401
      end
    end

    describe "docker search" do
      it "search" do
        @docker_repo.set_container_repository_name
        @docker_env_repo.set_container_repository_name
        per_page = 25
        scoped_results = {
          total: 100,
          subtotal: 2,
          page: 1,
          per_page: per_page,
          results: [@docker_repo, @docker_env_repo]
        }
        @controller.stubs(:scoped_search).returns(scoped_results)
        get :v1_search, params: { q: "abc", n: 2 }
        assert_response 200
        body = JSON.parse(response.body)
        assert_equal(body,
                      "num_results" => 2,
                      "query" => "abc",
                      "results" => [{ "name" => "puppet_product-busybox", "description" => nil },
                                    { "name" => "published_library_view-1_0-puppet_product-busybox", "description" => nil }]
                    )
      end

      it "show unauthenticated repositories" do
        repo = katello_repositories(:busybox_dev)
        repo.set_container_repository_name
        assert repo.save!
        repo.environment.registry_unauthenticated_pull = true
        assert repo.environment.save!

        @controller.stubs(:authenticate).returns(false)
        User.current = nil
        get :v1_search, params: { n: 2 }
        assert true
        assert_response 200
        body = JSON.parse(response.body)
        assert_equal 1, body["results"].length
        assert_equal "dev_label-published_dev_view-puppet_product-busybox", body["results"][0]["name"]
      end

      it "show two repositories" do
        User.current = User.find(users('admin').id)

        get :v1_search, params: { n: 4 }
        assert true
        assert_response 200
        body = JSON.parse(response.body)
        assert_equal body["results"].length, 4
      end
    end

    describe "docker pull" do
      it "pull manifest - protected" do
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)
        Resources::Registry::Proxy.stubs(:get).returns(stubbed: true)
        DockerMetaTag.stubs(:where).with(repository_id: @docker_repo.id, name: @tag.name).returns([@tag])

        allowed_perms = [:create_personal_access_tokens]
        denied_perms = []
        assert_protected_action(:pull_manifest, allowed_perms, denied_perms, [@organization]) do
          get :pull_manifest, params: { repository: @docker_repo.name, tag: @tag.name }
        end
      end

      it "pull manifest - success" do
        manifest = '{"mediaType":"MEDIATYPE"}'
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)
        Resources::Registry::Proxy.stubs(:get).returns(manifest)
        DockerMetaTag.stubs(:where).with(repository_id: @docker_repo.id, name: @tag.name).returns([@tag])

        get :pull_manifest, params: { repository: @docker_repo.name, tag: @tag.name }
        assert_response 200
        assert_equal(manifest, response.body)
        assert response.header['Content-Type'] =~ /MEDIATYPE/
        assert_equal response.header['Docker-Content-Digest'], "sha256:#{Digest::SHA256.hexdigest(manifest)}"
      end

      it "pull manifest no login - success" do
        manifest = '{"mediaType":"MEDIATYPE"}'
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)
        Resources::Registry::Proxy.stubs(:get).returns(manifest)
        DockerMetaTag.stubs(:where).with(repository_id: @docker_repo.id, name: @tag.name).returns([@tag])

        get :pull_manifest, params: { repository: @docker_repo.name, tag: @tag.name }
        assert_response 200
        assert_equal(manifest, response.body)
        assert response.header['Content-Type'] =~ /MEDIATYPE/
        assert_equal response.header['Docker-Content-Digest'], "sha256:#{Digest::SHA256.hexdigest(manifest)}"
      end
    end

    describe "docker push" do
      it "push manifest - error" do
        @controller.stubs(:authorize_repository_write).returns(true)
        put :push_manifest, params: { repository: 'repository', tag: 'tag' }
        assert_response 500
        body = JSON.parse(response.body)
        assert_equal "Unsupported schema ", body['error']['message']
      end

      it "push manifest - manifest.json exists" do
        File.open("#{Rails.root}/tmp/manifest.json", 'wb', 0600) do |file|
          file.write "empty manifest"
        end

        @controller.stubs(:authorize_repository_write).returns(true)
        put :push_manifest, params: { repository: 'repository', tag: 'tag' }
        assert_response 422
        body = JSON.parse(response.body)
        assert_equal "Upload already in progress", body['error']['message']
      end

      it "push manifest - success" do
        @repository = katello_repositories(:busybox)
        mock_pulp_server([
                           { name: :create_upload_request, result: { 'upload_id' => 123 }, count: 2 },
                           { name: :delete_upload_request, result: true, count: 2 },
                           { name: :upload_bits, result: true, count: 1 }
                         ])
        @controller.expects(:sync_task)
          .times(2)
          .returns(stub('task', :output => {'upload_results' => [{ 'digest' => 'sha256:1234' }]}), true)
          .with do |action_class, repository, upload_ids, params|
            assert_equal ::Actions::Katello::Repository::ImportUpload, action_class
            assert_equal @repository, repository
            assert_equal [123], upload_ids
            if params[:unit_type_id] == 'docker_manifest'
              assert_equal [:checksum, :name, :size], params[:unit_keys][0].keys.sort
            elsif params[:unit_type_id] == 'docker_tag'
              assert_equal [{name: 'tag', digest: 'sha256:1234'}], params[:unit_keys]
            else
              assert_equal "unknown unit_type_id", params[:unit_type_id]
            end
            assert_equal true, params[:generate_metadata]
            assert_equal true, params[:sync_capsule]
          end

        manifest = {
          schemaVersion: 1
        }
        @controller.stubs(:authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@repository)
        @controller.stubs(:find_writable_repository).returns(@repository)
        put :push_manifest, params: { repository: 'repository', tag: 'tag' },
            body: manifest.to_json
        assert_response 200
      end
    end

    def mock_pulp_server(content_hash)
      content = mock
      content_hash.each do |method|
        content.stubs(method[:name]).times(method[:count]).returns(method[:result])
      end
      @controller.stubs(:pulp_content).returns(content)
    end
  end
  #rubocop:enable Metrics/BlockLength
end
