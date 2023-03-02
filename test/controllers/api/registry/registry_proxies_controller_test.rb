require "katello_test_helper"

#rubocop:disable Metrics/ModuleLength
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
      @digest = 'sha256:somedigest'
      @length = '0'
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

      SETTINGS[:katello][:container_image_registry] = {crane_url: 'https://localhost:5000', crane_ca_cert_file: '/etc/pki/katello/certs/katello-default-ca.crt', allow_push: true}
      File.delete("#{Rails.root}/tmp/manifest.json") if File.exist?("#{Rails.root}/tmp/manifest.json")
    end

    describe "docker login" do
      it "ping - with cert" do
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

        get :token, params: { account: User.name }
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

        get :token, params: { account: User.name }
        assert_response 200
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        body = JSON.parse(response.body)
        assert_equal "12345", body['token']
        assert_equal "#{expiration}", body['expires_at']
        assert_equal "#{expiration}", body['issued_at']
      end

      it "token - unscoped is authorized" do
        User.current = nil
        session[:user] = nil
        reset_api_credentials

        get :token
        assert_response 200
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

      it "token - allow cert-based pull" do
        @docker_repo.set_container_repository_name
        @docker_repo.save!
        @docker_repo.environment.registry_unauthenticated_pull = false
        @docker_repo.environment.save!

        User.current = nil
        session[:user] = nil
        reset_api_credentials

        request.headers.merge!(HTTP_SSL_CLIENT_VERIFY: 'SUCCESS', HTTP_SSL_CLIENT_S_DN: "O=#{@docker_repo.organization.label}")
        get :token, params: { scope: "repository:#{@docker_repo.container_repository_name}:pull" }
        assert_response 200
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

    describe "catalog" do
      it "displays all images for authenticated requests" do
        @docker_repo.set_container_repository_name
        @docker_env_repo.set_container_repository_name
        org = @docker_repo.organization

        repo = katello_repositories(:busybox_dev)
        repo.set_container_repository_name
        assert repo.save!
        repo.environment.registry_unauthenticated_pull = false
        assert repo.environment.save!

        get :catalog
        assert_response 200
        body = JSON.parse(response.body)
        assert_equal(body['repositories'].compact.sort,
                     ["busybox",
                      "empty_organization-dev_label-published_dev_view-puppet_product-busybox",
                      "#{org.label.downcase}-puppet_product-busybox"])
      end

      it "shows only available images for unauthenticated requests" do
        @docker_repo.set_container_repository_name
        @docker_env_repo.set_container_repository_name
        @docker_repo.environment.registry_unauthenticated_pull = true
        assert @docker_repo.environment.save!

        User.current = nil
        session[:user] = nil
        reset_api_credentials

        get :catalog
        assert_response 200
        body = JSON.parse(response.body)
        assert_equal(["busybox", "empty_organization-puppet_product-busybox"], body['repositories'].compact.sort)
      end
    end

    describe "docker search" do
      it "search" do
        @docker_repo.set_container_repository_name
        @docker_env_repo.set_container_repository_name
        org = @docker_repo.organization
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
                      "results" => [{ "name" => "#{org.label.downcase}-puppet_product-busybox", "description" => nil },
                                    { "name" => "#{org.label.downcase}-published_library_view-1_0-puppet_product-busybox", "description" => nil }]
                    )
      end

      it "blocks search for podman" do
        @docker_repo.set_container_repository_name
        @docker_env_repo.set_container_repository_name
        @request.env['HTTP_USER_AGENT'] = "libpod/1.8.0"
        get :v1_search, params: { q: "abc", n: 2 }
        assert_response 404
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
        assert_equal "#{repo.organization.label.downcase}-dev_label-published_dev_view-puppet_product-busybox", body["results"][0]["name"]
      end

      it "show unauthenticated repositories for head requests" do
        repo = katello_repositories(:busybox_dev)
        repo.set_container_repository_name
        assert repo.save!
        repo.environment.registry_unauthenticated_pull = true
        assert repo.environment.save!

        @controller.stubs(:authenticate).returns(false)
        User.current = nil
        head :v1_search, params: { n: 2 }
        assert true
        assert_response 200
      end

      it "does not show archived versions" do
        User.current = User.find(users('admin').id)
        repo = katello_repositories(:busybox)
        repo.set_container_repository_name
        repo.environment_id = nil
        assert repo.save!
        assert repo.archive?

        non_archive_repo = katello_repositories(:busybox_dev)
        non_archive_repo.set_container_repository_name
        non_archive_repo.save!
        refute non_archive_repo.archive?

        get :v1_search
        assert_response 200
        body = JSON.parse(response.body)

        refute_includes body["results"],
          { "name" => repo.container_repository_name, "description" => nil }
        assert_includes body["results"],
          { "name" => non_archive_repo.container_repository_name, "description" => nil }
      end

      it "shows N repositories" do
        User.current = User.find(users('admin').id)

        get :v1_search, params: { n: 2 }
        assert_response 200
        body = JSON.parse(response.body)
        assert_equal 2, body["results"].length
      end
    end

    describe "docker pull" do
      it "pull manifest - protected" do
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)
        Resources::Registry::Proxy.stubs(:get).returns(stubbed: true)
        DockerMetaTag.stubs(:where).with(id: RepositoryDockerMetaTag.
                                         where(repository_id: @docker_repo.id).
                                         select(:docker_meta_tag_id), name: @tag.name).returns([@tag])

        allowed_perms = [:create_personal_access_tokens]
        denied_perms = []
        assert_protected_action(:pull_manifest, allowed_perms, denied_perms, [@organization]) do
          get :pull_manifest, params: { repository: @docker_repo.name, tag: @tag.name }
        end
      end

      it "pull manifest - success" do
        manifest = '{"mediaType":"MEDIATYPE"}'
        manifest.stubs(:headers).returns({docker_content_digest: @digest, content_length: @length, content_type: 'MEDIATYPE'})
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)
        Resources::Registry::Proxy.stubs(:get).returns(manifest)
        DockerMetaTag.stubs(:where).with(id: RepositoryDockerMetaTag.
                                         where(repository_id: @docker_repo.id).
                                         select(:docker_meta_tag_id), name: @tag.name).returns([@tag])

        get :pull_manifest, params: { repository: @docker_repo.name, tag: @tag.name }
        assert_response 200
        assert_equal(manifest, response.body)
        assert_equal response.header['Content-Length'], '0'
        assert response.header['Content-Type'] =~ /MEDIATYPE/
        assert_equal @digest, response.header['Docker-Content-Digest']
      end

      it "pull manifest - HTTPS Header" do
        #production installs include an HTTPS: 'on' header, which needs to be removed
        manifest = '{"mediaType":"MEDIATYPE"}'
        manifest.stubs(:headers).returns({docker_content_digest: @digest, content_length: @length, content_type: 'MEDIATYPE'})
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)

        request.env['HTTPS'] = 'on' #should not be passed through
        request.env['HTTP_FOO'] = 'bar' #should be passed through

        expected_headers = {"HOST" => "test.host", "USER-AGENT" => "Rails Testing", "AUTHORIZATION" => "Basic YXBpYWRtaW46c2VjcmV0",
                            "ACCEPT" => "application/json", "ACCEPT-LANGUAGE" => "en-US", "FOO" => "bar", "COOKIE" => ""}
        expected_headers['AUTHORIZATION'] = request.env['HTTP_AUTHORIZATION']

        Resources::Registry::Proxy.stubs(:get).with('/v2/busybox/manifests/one', expected_headers).returns(manifest)
        DockerMetaTag.stubs(:where).with(id: RepositoryDockerMetaTag.
                                         where(repository_id: @docker_repo.id).
                                         select(:docker_meta_tag_id), name: @tag.name).returns([@tag])

        get :pull_manifest, params: { repository: @docker_repo.name, tag: @tag.name }
        assert_response 200
        assert_equal(manifest, response.body)
        assert_equal response.header['Content-Length'], '0'
        assert response.header['Content-Type'] =~ /MEDIATYPE/
        assert_equal @digest, response.header['Docker-Content-Digest']
      end

      it "pull manifest - HTTP Header - v1+json" do
        manifest = '{}'
        manifest.stubs(:headers).returns({docker_content_digest: @digest, content_length: @length, content_type: 'MEDIATYPE'})
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)
        Resources::Registry::Proxy.stubs(:get).returns(manifest)
        DockerMetaTag.stubs(:where).with(id: RepositoryDockerMetaTag.
                                         where(repository_id: @docker_repo.id).
                                         select(:docker_meta_tag_id), name: @tag.name).returns([@tag])

        get :pull_manifest, params: { repository: @docker_repo.name, tag: @tag.name }
        assert_response 200
        assert_equal(manifest, response.body)
        assert_includes response.header['Content-Type'], 'MEDIATYPE'
        assert_equal response.header['Content-Length'], '0'
        assert_equal @digest, response.header['Docker-Content-Digest']
      end

      it "pull manifest - HTTP Header - with signatures" do
        manifest = '{"signatures": [{"signature":"...."}]}'
        manifest.stubs(:headers).returns({docker_content_digest: @digest, content_length: @length, content_type: 'MEDIATYPE'})
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)
        Resources::Registry::Proxy.stubs(:get).returns(manifest)
        DockerMetaTag.stubs(:where).with(id: RepositoryDockerMetaTag.
                                         where(repository_id: @docker_repo.id).
                                         select(:docker_meta_tag_id), name: @tag.name).returns([@tag])

        get :pull_manifest, params: { repository: @docker_repo.name, tag: @tag.name }
        assert_response 200
        assert_equal(manifest, response.body)
        assert_equal response.header['Content-Length'], @length
        assert_includes response.header['Content-Type'], 'MEDIATYPE'
        assert_equal @digest, response.header['Docker-Content-Digest']
      end

      it "pull manifest no login - success" do
        manifest = '{"mediaType":"MEDIATYPE"}'
        manifest.stubs(:headers).returns({docker_content_digest: @digest, content_length: @length, content_type: 'MEDIATYPE'})

        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)
        Resources::Registry::Proxy.stubs(:get).returns(manifest)
        DockerMetaTag.stubs(:where).with(id: RepositoryDockerMetaTag.
                                         where(repository_id: @docker_repo.id).
                                         select(:docker_meta_tag_id), name: @tag.name).returns([@tag])

        get :pull_manifest, params: { repository: @docker_repo.name, tag: @tag.name }
        assert_response 200
        assert_equal(manifest, response.body)
        assert_equal response.header['Content-Length'], '0'
        assert response.header['Content-Type'] =~ /MEDIATYPE/
        assert_equal @digest, response.header['Docker-Content-Digest']
      end

      it "pull manifest repo not found" do
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(nil)

        get :pull_manifest, params: { repository: "doesnotexist", tag: "latest" }
        assert_response 404
        response_body = JSON.parse(response.body)
        assert response_body['errors'].length >= 1
        response_body['errors'].first.assert_valid_keys('code', 'message', 'details')
      end

      it "pull manifest repo tag not found" do
        manifest = '{"mediaType":"MEDIATYPE"}'
        @controller.stubs(:registry_authorize).returns(true)
        @controller.stubs(:find_readable_repository).returns(@docker_repo)
        Resources::Registry::Proxy.stubs(:get).returns(manifest)

        get :pull_manifest, params: { repository: @docker_repo.name, tag: "doesnotexist" }
        assert_response 404
        response_body = JSON.parse(response.body)
        assert response_body['errors'].length >= 1
        response_body['errors'].first.assert_valid_keys('code', 'message', 'details')
      end
    end

    # Disabling docker push tests until it is implemented for Pulp 3.
    # describe "docker push" do
    #   it "push manifest - error" do
    #     @controller.stubs(:authorize_repository_write).returns(true)
    #     put :push_manifest, params: { repository: 'repository', tag: 'tag' }
    #     assert_response 500
    #     body = JSON.parse(response.body)
    #     assert_equal "Unsupported schema ", body['error']['message']
    #   end

    #   it "push manifest - manifest.json exists" do
    #     File.open("#{Rails.root}/tmp/manifest.json", 'wb', 0600) do |file|
    #       file.write "empty manifest"
    #     end

    #     @controller.stubs(:authorize_repository_write).returns(true)
    #     put :push_manifest, params: { repository: 'repository', tag: 'tag' }
    #     assert_response 422
    #     body = JSON.parse(response.body)
    #     assert_equal "Upload already in progress", body['error']['message']
    #   end

    #   it "push manifest - success" do
    #     @repository = katello_repositories(:busybox)
    #     mock_pulp_server([
    #                        { name: :create_upload_request, result: { 'upload_id' => 123 }, count: 2 },
    #                        { name: :delete_upload_request, result: true, count: 2 },
    #                        { name: :upload_bits, result: true, count: 1 }
    #                      ])
    #     @controller.expects(:sync_task)
    #       .times(2)
    #       .returns(stub('task', :output => {'upload_results' => [{ 'digest' => 'sha256:1234' }]}), true)
    #       .with do |action_class, repository, uploads, params|
    #         assert_equal ::Actions::Katello::Repository::ImportUpload, action_class
    #         assert_equal @repository, repository
    #         assert_equal [123], uploads.pluck(:id)
    #         assert params[:generate_metadata]
    #         assert params[:sync_capsule]
    #       end

    #     manifest = {
    #       schemaVersion: 1
    #     }
    #     @controller.stubs(:authorize).returns(true)
    #     @controller.stubs(:find_readable_repository).returns(@repository)
    #     @controller.stubs(:find_writable_repository).returns(@repository)
    #     put :push_manifest, params: { repository: 'repository', tag: 'tag' },
    #         body: manifest.to_json
    #     assert_response 200
    #   end

    #   it "push manifest - disabled with false" do
    #     SETTINGS[:katello][:container_image_registry] = {crane_url: 'https://localhost:5000', crane_ca_cert_file: '/etc/pki/katello/certs/katello-default-ca.crt', allow_push: false}
    #     put :push_manifest, params: { repository: 'repository', tag: 'tag' }
    #     assert_response 404
    #     body = JSON.parse(response.body)
    #     assert_equal "Registry push not supported", body['error']['message']
    #   end

    #   it "push manifest - disabled by omission" do
    #     SETTINGS[:katello][:container_image_registry] = {crane_url: 'https://localhost:5000', crane_ca_cert_file: '/etc/pki/katello/certs/katello-default-ca.crt'}
    #     put :push_manifest, params: { repository: 'repository', tag: 'tag' }
    #     assert_response 404
    #     body = JSON.parse(response.body)
    #     assert_equal "Registry push not supported", body['error']['message']
    #   end
    # end

    # def mock_pulp_server(content_hash)
    #   content = mock
    #   content_hash.each do |method|
    #     content.stubs(method[:name]).times(method[:count]).returns(method[:result])
    #   end
    #   @controller.stubs(:pulp_content).returns(content)
    # end
  end
  #rubocop:enable Metrics/BlockLength
end
