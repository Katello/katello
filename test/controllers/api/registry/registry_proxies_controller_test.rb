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
        issue_time = Time.now
        expiry_time = 30.minutes.from_now
        tolerance = 3.seconds

        token = mock('token')
        token.stubs(:token).returns("12345")
        token.stubs(:generate_token).returns("12345")
        token.stubs(:user_id).returns(User.current.id)
        token.stubs(:expires_at).returns("#{expiry_time.rfc3339}")
        token.stubs(:created_at).returns("#{issue_time.rfc3339}")
        token.stubs('save!').returns(true)
        PersonalAccessToken.expects(:new).returns(token)

        get :token, params: { account: User.name }
        assert_response 200
        assert_equal 'registry/2.0', response.headers['Docker-Distribution-API-Version']
        body = JSON.parse(response.body)
        assert_equal "12345", body['token']

        response_issue_time = body['issued_at'].to_time
        response_expiry_time = response_issue_time + body['expires_in'].seconds
        assert (response_expiry_time - tolerance) < expiry_time
        assert (response_expiry_time + tolerance) > expiry_time
      end

      it "token - has 'registry' token" do
        issue_time = Time.now
        expiry_time = 30.minutes.from_now
        tolerance = 3.seconds

        token = mock('token')
        token.stubs(:token).returns("12345")
        token.stubs(:generate_token).returns("12345")
        token.stubs(:user_id).returns(User.current.id)
        token.stubs(:expires_at).returns(expiry_time.rfc3339)
        token.stubs(:created_at).returns(issue_time.rfc3339)
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

        response_issue_time = body['issued_at'].to_time
        response_expiry_time = response_issue_time + body['expires_in'].seconds
        assert (response_expiry_time - tolerance) < expiry_time
        assert (response_expiry_time + tolerance) > expiry_time
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
          results: [@docker_repo, @docker_env_repo],
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
        @request.env['HTTP_DOCKER_DISTRIBUTION_API_VERSION'] = "registry/2.0"
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

    describe 'container push' do
      it 'starts a blob upload to Pulp' do
        repo_name = 'test_org/test_product/test_name'
        @controller.expects(:check_blob_push_org_label).returns(true)
        @controller.expects(:check_blob_push_product_label).returns(true)
        @controller.expects(:check_blob_push_container).returns(true)
        @controller.expects(:create_container_repo_if_needed)
        @controller.expects(:save_push_repo_hrefs).returns(true)
        mock_root_repo = mock('root_repo')
        mock_instance_repo = mock('instance_repo')
        mock_root_repo.stubs(:library_instance).returns(mock_instance_repo)
        @controller.stubs(:root_repository).returns(mock_root_repo)

        # The content type should be octet-stream, but action controller
        # throws a non-existence error since Mime::Type.lookup('application/octet-stream').to_sym is nil.
        Resources::Registry::Proxy.expects(:post).with(
              "/v2/#{repo_name}/blobs/uploads",
              is_a(StringIO),
              has_entries('MOCK-TEST' => 123,
                          'Content-Type' => 'application/json',
                          'Content-Length' => '2')
            ).returns(mock_pulp_response(202, { 'Location' => 'Mars' }))
        request.env['HTTP_MOCK_TEST'] = 123
        request.headers['Content-Type'] = 'application/json'
        resp = post :start_upload_blob, params: { repository: repo_name }
        assert_equal resp.code, '202'
        assert_equal 'Mars', resp.headers['Location']
      end

      it 'uploads a blob chunk' do
        repo_name = 'test_org/test_product/test_name'
        uuid = 'uuid'
        @controller.expects(:check_blob_push_org_label).returns(true)
        @controller.expects(:check_blob_push_product_label).returns(true)
        @controller.expects(:check_blob_push_container).returns(true)
        @controller.expects(:create_container_repo_if_needed)
        @controller.expects(:save_push_repo_hrefs).returns(true)
        mock_root_repo = mock('root_repo')
        mock_instance_repo = mock('instance_repo')
        mock_root_repo.stubs(:library_instance).returns(mock_instance_repo)
        @controller.stubs(:root_repository).returns(mock_root_repo)

        # The content type should be octet-stream, but action controller
        # throws a non-existence error since Mime::Type.lookup('application/octet-stream').to_sym is nil.
        Resources::Registry::Proxy.expects(:patch).with(
              "/v2/#{repo_name}/blobs/uploads/#{uuid}",
              '{}',
              has_entries('MOCK-TEST' => 123,
                          'Content-Type' => 'application/json',
                          'Content-Range' => 'bytes 500-1000/65989',
                          'Content-Length' => '2')
            ).returns(mock_pulp_response(202, { 'Location' => 'Mars' }))
        request.env['HTTP_MOCK_TEST'] = 123
        request.headers['Content-Type'] = 'application/json'
        request.headers['Content-Range'] = 'bytes 500-1000/65989'
        request.env['HTTP_MOCK_TEST'] = 123
        resp = patch :upload_blob, params: { repository: repo_name, uuid: uuid }
        assert_equal resp.code, '202'
        assert_equal 'Mars', resp.headers['Location']
      end

      it 'finishes a blob upload to Pulp' do
        repo_name = 'test_org/test_product/test_name'
        uuid = 'uuid'
        @controller.expects(:check_blob_push_org_label).returns(true)
        @controller.expects(:check_blob_push_product_label).returns(true)
        @controller.expects(:check_blob_push_container).returns(true)
        @controller.expects(:create_container_repo_if_needed)
        @controller.expects(:save_push_repo_hrefs).returns(true)
        mock_root_repo = mock('root_repo')
        mock_instance_repo = mock('instance_repo')
        mock_root_repo.stubs(:library_instance).returns(mock_instance_repo)
        @controller.stubs(:root_repository).returns(mock_root_repo)

        # The content type should be octet-stream, but action controller
        # throws a non-existence error since Mime::Type.lookup('application/octet-stream').to_sym is nil.
        Resources::Registry::Proxy.expects(:put).with(
              "/v2/#{repo_name}/blobs/uploads/#{uuid}",
              is_a(StringIO),
              has_entries('MOCK-TEST' => 123,
                          'Content-Type' => 'application/json',
                          'Content-Range' => 'bytes 500-1000/65989',
                          'Content-Length' => '2')
            ).returns(mock_pulp_response(201, { 'Location' => 'Mars' }))
        request.env['HTTP_MOCK_TEST'] = 123
        request.headers['Content-Type'] = 'application/json'
        request.headers['Content-Range'] = 'bytes 500-1000/65989'
        resp = put :finish_upload_blob, params: { repository: repo_name, uuid: uuid }
        assert_equal resp.code, '201'
        assert_equal 'Mars', resp.headers['Location']
      end

      it 'pushes a manifest and indexes content' do
        repo_name = 'test_org/test_product/test_name'
        tag = 'latest'
        @controller.expects(:check_blob_push_org_label).returns(true)
        @controller.expects(:check_blob_push_product_label).returns(true)
        @controller.expects(:check_blob_push_container).returns(true)
        @controller.expects(:create_container_repo_if_needed)
        @controller.expects(:save_push_repo_hrefs).returns(true)
        mock_root_repo = mock('root_repo')
        mock_instance_repo = mock('instance_repo')
        mock_instance_repo.expects(:index_content)
        mock_root_repo.stubs(:library_instance).returns(mock_instance_repo)
        @controller.stubs(:root_repository).returns(mock_root_repo)

        # The content type should be application/vnd.oci.image.manifest.v1+json, but action controller
        # throws a non-existence error since Mime::Type.lookup('application/octet-stream').to_sym is nil.
        Resources::Registry::Proxy.expects(:put).with(
              "/v2/#{repo_name}/manifests/#{tag}",
              '{}',
              has_entries('MOCK-TEST' => 123,
                          'Content-Type' => 'application/json')
            ).returns(mock_pulp_response(201, { 'Location' => 'Mars' }))
        request.env['HTTP_MOCK_TEST'] = 123
        request.headers['Content-Type'] = 'application/json'
        resp = put :push_manifest, params: { repository: repo_name, tag: tag }
        assert_equal 'Mars', resp.headers['Location']
        assert_equal resp.code, '201'
      end

      it 'parses valid blob push properties' do
        path_strings = [
          "/v2/foo/bar/baz/blobs/uploads",
          "/v2/foo/bar/baz/manifests/q",
          "/v2/underscore_org/product-dashed/name_numbered_12/blobs/uploads",
          "/v2/foo/bar/baz/blobs/uploads?qwertyuiop=asdfghjkl",
          "/v2/foo/bar/baz/manifests/additional/directories/after/name",
          "/v2/id/0/0/foo/blobs/uploads",
          "/v2/id/867/5309/foo/blobs/uploads?qwertyuiop=asdfghjkl"
        ]
        results = [
          {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"},
          {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"},
          {valid_format: true, schema: "label", organization: "underscore_org", product: "product-dashed", name: "name_numbered_12"},
          {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"},
          {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"},
          {valid_format: true, schema: "id", organization: "0", product: "0", name: "foo"},
          {valid_format: true, schema: "id", organization: "867", product: "5309", name: "foo"}
        ]
        path_strings.each_index do |i|
          actual_result = @controller.parse_blob_push_props(path_strings[i])

          # checking like this because actual result will contain path strings, etc
          results[i].each do |key, value|
            assert_equal value, actual_result[key]
          end
        end
      end

      it 'rejects invalid blob push properties' do
        path_strings = [
          "/wrong",
          "/v2/wrong",
          "/v2/foo/wrong",
          "/v2/foo/bar/wrong",
          "/v2/foo/bar/baz/wrong",
          "/v2/foo/bar/baz/blobs/",
          "/v2/foo/bar/baz/manifests",
          "/v2/id/",
          "/v2/id/wrong",
          "/v2/id/0/wrong",
          "/v2/id/0/0/wrong",
          "/v2/id/0/0/foo/wrong",
          "/v2/id/0/0/foo/blobs/",
          "/v2/id/0/0/foo/manifests/"
        ]
        path_strings.each do |path_string|
          result = @controller.parse_blob_push_props(path_string)
          refute result[:valid_format]
        end
      end

      it 'renders error on invalid blob properties' do
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_field_syntax({valid_format: false})
      end

      it 'determines correct org with label' do
        mock_org = mock('Organization')
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"}
        Organization.stubs(:where).with("LOWER(label) = '#{props[:organization]}'").returns([mock_org])
        assert @controller.check_blob_push_org_label(props)
        assert_equal mock_org, @controller.instance_variable_get(:@organization)
      end

      it 'determines correct org with id' do
        mock_org = mock('Organization')
        props = {valid_format: true, schema: "id", organization: "0", product: "0", name: "foo"}
        Organization.stubs(:find_by_id).with(props[:organization].to_i).returns(mock_org)
        assert @controller.check_blob_push_org_id(props)
        assert_equal mock_org, @controller.instance_variable_get(:@organization)
      end

      it 'rejects missing org label' do
        props = {valid_format: true, schema: "label", product: "bar", name: "baz"}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_org_label(props)
      end

      it 'rejects blank org label' do
        props = {valid_format: true, schema: "label", organization: "", product: "bar", name: "baz"}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_org_label(props)
      end

      it 'rejects ambiguous org label with existing repo' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"}
        mock_root_repo1 = mock('root_repository')
        mock_root_repo1.stubs(:label).returns(props[:name])
        mock_root_repos1 = mock('root_repositories')
        mock_root_repos1.stubs(:where).with(label: props[:name]).returns([mock_root_repo1])
        mock_prod1 = mock('product')
        mock_prod1.stubs(:root_repositories).returns(mock_root_repos1)
        mock_prod1.stubs(:label).returns(props[:product])
        mock_products1 = mock('products')
        mock_products1.stubs(:where).with("LOWER(label) = '#{props[:product]}'").returns([mock_prod1])
        mock_org1 = mock('Organization')
        mock_org1.stubs(:products).returns(mock_products1)
        mock_org1.stubs(:name).returns(props[:organization])
        mock_org1.stubs(:id).returns(0)
        mock_org1.stubs(:label).returns(props[:organization])
        mock_org2 = mock('Organization')
        Organization.stubs(:where).with("LOWER(label) = '#{props[:organization]}'").returns([mock_org1, mock_org2])
        expect_render_podman_error("NAME_INVALID", :conflict)
        refute @controller.check_blob_push_org_label(props)
      end

      it 'rejects ambiguous org label without existing repo' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"}
        mock_products1 = mock('products')
        mock_products1.stubs(:where).with("LOWER(label) = '#{props[:product]}'").returns([])
        mock_org1 = mock('Organization')
        mock_org1.stubs(:products).returns(mock_products1)
        mock_products2 = mock('products')
        mock_products2.stubs(:where).with("LOWER(label) = '#{props[:product]}'").returns([])
        mock_org2 = mock('Organization')
        mock_org2.stubs(:products).returns(mock_products2)
        Organization.stubs(:where).with("LOWER(label) = '#{props[:organization]}'").returns([mock_org1, mock_org2])
        expect_render_podman_error("NAME_INVALID", :conflict)
        refute @controller.check_blob_push_org_label(props)
      end

      it 'rejects org label when no org exists' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"}
        Organization.stubs(:where).with("LOWER(label) = '#{props[:organization]}'").returns([])
        expect_render_podman_error("NAME_UNKNOWN", :not_found)
        refute @controller.check_blob_push_org_label(props)
      end

      it 'rejects missing org id' do
        props = {valid_format: true, schema: "id", product: "0", name: "foo"}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_org_id(props)
      end

      it 'rejects non-integer org id' do
        props = {valid_format: true, schema: "id", organization: "invalid", product: "0", name: "foo"}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_org_id(props)
      end

      it 'rejects org id when no org exists' do
        props = {valid_format: true, schema: "id", organization: "0", product: "0", name: "foo"}
        Organization.stubs(:find_by_id).with(props[:organization].to_i).returns([])
        expect_render_podman_error("NAME_UNKNOWN", :not_found)
        refute @controller.check_blob_push_org_label(props)
      end

      it 'determines correct prod with label' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"}
        mock_prod = mock('Product')
        mock_products = mock('products')
        mock_products.stubs(:where).with("LOWER(label) = '#{props[:product]}'").returns([mock_prod])
        mock_org = mock('Organization')
        mock_org.stubs(:products).returns(mock_products)
        @controller.instance_variable_set(:@organization, mock_org)

        assert @controller.check_blob_push_product_label(props)
        assert_equal mock_prod, @controller.instance_variable_get(:@product)
      end

      it 'determines correct prod with id' do
        props = {valid_format: true, schema: "id", organization: "0", product: "0", name: "foo"}
        mock_prod = mock('Product')
        mock_products = mock('products')
        mock_products.stubs(:find_by_id).with(props[:product].to_i).returns(mock_prod)
        mock_org = mock('Organization')
        mock_org.stubs(:products).returns(mock_products)
        @controller.instance_variable_set(:@organization, mock_org)

        assert @controller.check_blob_push_product_id(props)
        assert_equal mock_prod, @controller.instance_variable_get(:@product)
      end

      it 'rejects missing prod label' do
        props = {valid_format: true, schema: "label", organization: "foo", name: "baz"}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_product_label(props)
      end

      it 'rejects blank prod label' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "", name: "baz"}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_product_label(props)
      end

      it 'rejects ambiguous prod label with existing repo' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"}
        mock_root_repo1 = mock('root_repository')
        mock_root_repo1.stubs(:label).returns(props[:name])
        mock_root_repos1 = mock('root_repositories')
        mock_root_repos1.stubs(:where).with(label: props[:name]).returns([mock_root_repo1])
        mock_prod1 = mock('Product')
        mock_prod1.stubs(:root_repositories).returns(mock_root_repos1)
        mock_prod1.stubs(:name).returns(props[:product])
        mock_prod1.stubs(:label).returns(props[:product])
        mock_prod1.stubs(:id).returns(0)
        mock_prod2 = mock('Product')
        mock_products = mock('products')
        mock_products.stubs(:where).with("LOWER(label) = '#{props[:product]}'").returns([mock_prod1, mock_prod2])
        mock_org = mock('Organization')
        mock_org.stubs(:label).returns(props[:organization])
        mock_org.stubs(:products).returns(mock_products)
        @controller.instance_variable_set(:@organization, mock_org)
        expect_render_podman_error("NAME_INVALID", :conflict)
        refute @controller.check_blob_push_product_label(props)
      end

      it 'rejects ambiguous prod label without existing repo' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"}
        mock_root_repos1 = mock('root_repositories')
        mock_root_repos1.stubs(:where).with(label: props[:name]).returns([])
        mock_prod1 = mock('Product')
        mock_prod1.stubs(:root_repositories).returns(mock_root_repos1)
        mock_root_repos2 = mock('root_repositories')
        mock_root_repos2.stubs(:where).with(label: props[:name]).returns([])
        mock_prod2 = mock('Product')
        mock_prod2.stubs(:root_repositories).returns(mock_root_repos1)
        mock_products = mock('products')
        mock_products.stubs(:where).with("LOWER(label) = '#{props[:product]}'").returns([mock_prod1, mock_prod2])
        mock_org = mock('Organization')
        mock_org.stubs(:label).returns(props[:organization])
        mock_org.stubs(:products).returns(mock_products)
        @controller.instance_variable_set(:@organization, mock_org)
        expect_render_podman_error("NAME_INVALID", :conflict)
        refute @controller.check_blob_push_product_label(props)
      end

      it 'rejects prod label when no prod exists' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"}
        mock_products = mock('products')
        mock_products.stubs(:where).with("LOWER(label) = '#{props[:product]}'").returns([])
        mock_org = mock('Organization')
        mock_org.stubs(:products).returns(mock_products)
        @controller.instance_variable_set(:@organization, mock_org)
        expect_render_podman_error("NAME_UNKNOWN", :not_found)
        refute @controller.check_blob_push_product_label(props)
      end

      it 'rejects missing prod id' do
        props = {valid_format: true, schema: "id", organization: "0", name: "foo"}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_product_id(props)
      end

      it 'rejects non-integer prod id' do
        props = {valid_format: true, schema: "id", organization: "0", product: "invalid", name: "foo"}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_product_id(props)
      end

      it 'rejects prod id when no prod exists' do
        props = {valid_format: true, schema: "id", organization: "0", product: "0", name: "foo"}
        mock_products = mock('products')
        mock_products.stubs(:find_by_id).with(props[:product].to_i).returns(nil)
        mock_org = mock('Organization')
        mock_org.stubs(:products).returns(mock_products)
        @controller.instance_variable_set(:@organization, mock_org)
        expect_render_podman_error("NAME_UNKNOWN", :not_found)
        refute @controller.check_blob_push_product_id(props)
      end

      it 'sets container names correctly with label format' do
        prop_list = [
          {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"},
          {valid_format: true, schema: "label", organization: "default_organization", product: "test_product", name: "test_name"},
          {valid_format: true, schema: "id", organization: "0", product: "0", name: "test_name"},
          {valid_format: true, schema: "id", organization: "867", product: "5309", name: "foo"}
        ]
        prop_list.each do |props|
          mock_root_repo = mock('root_repository')
          mock_root_repo.stubs(:container_push_name_format).returns(props[:schema])
          mock_root_repositories = mock('root_repositories')
          mock_root_repositories.stubs(:where).with(label: props[:name]).returns([mock_root_repo])
          mock_product = mock('Product')
          mock_product.stubs(:root_repositories).returns(mock_root_repositories)
          @controller.instance_variable_set(:@product, mock_product)

          assert @controller.check_blob_push_container(props)
          assert_equal props[:name], @controller.instance_variable_get(:@container_name)
          assert_equal props[:schema], @controller.instance_variable_get(:@container_push_name_format)
          if props[:schema] == "label"
            assert_equal "#{props[:organization]}/#{props[:product]}/#{props[:name]}", @controller.instance_variable_get(:@container_path_input)
          else
            assert_equal "id/#{props[:organization]}/#{props[:product]}/#{props[:name]}", @controller.instance_variable_get(:@container_path_input)
          end
        end
      end

      it 'rejects container when name is missing' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar"}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_container(props)
      end

      it 'rejects container when name is blank' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: ""}
        expect_render_podman_error("NAME_INVALID", :bad_request)
        refute @controller.check_blob_push_container(props)
      end

      it 'rejects containers with mismatching push name format' do
        props = {valid_format: true, schema: "label", organization: "foo", product: "bar", name: "baz"}
        mock_root_repo = mock('root_repository')
        mock_root_repo.stubs(:container_push_name_format).returns("id")
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: props[:name]).returns([mock_root_repo])
        mock_product = mock('Product')
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)
        @controller.instance_variable_set(:@product, mock_product)
        expect_render_podman_error("NAME_INVALID", :conflict)
        refute @controller.check_blob_push_container(props)
      end

      it 'creates a container repo if authorized' do
        container_name = "foo"
        container_push_name = "default_org/test/foo"
        container_push_name_format = "label"
        mock_root_repo = mock('root_repository')
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([])
        mock_product = mock('Product')
        mock_product.expects(:syncable?).returns(true)
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)
        mock_product.expects(:add_repo).with(
          name: container_name,
          label: container_name,
          download_policy: 'immediate',
          content_type: Repository::DOCKER_TYPE,
          unprotected: true,
          is_container_push: true,
          container_push_name: container_push_name,
          container_push_name_format: container_push_name_format
        ).returns(mock_root_repo)
        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        @controller.instance_variable_set(:@container_path_input, container_push_name)
        @controller.instance_variable_set(:@container_push_name_format, container_push_name_format)
        @controller.expects(:sync_task).with(
          ::Actions::Katello::Repository::CreateRoot,
          mock_root_repo,
          container_push_name
        ).returns(true)
        assert @controller.create_container_repo_if_needed
      end

      it 'does not create container repo when unauthorized' do
        container_name = "foo"
        container_push_name = "default_org/test/foo"
        container_push_name_format = "label"
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([])
        mock_product = mock('Product')
        mock_product.expects(:syncable?).returns(false)
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)
        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        @controller.instance_variable_set(:@container_path_input, container_push_name)
        @controller.instance_variable_set(:@container_push_name_format, container_push_name_format)
        expect_render_podman_error("DENIED", :not_found)
        refute @controller.create_container_repo_if_needed
      end

      it 'does not create container repo if it already exists' do
        container_name = "foo"
        mock_root_repo = mock('root_repository')
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([mock_root_repo])
        mock_product = mock('Product')
        mock_product.expects(:syncable?).returns(true)
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)
        mock_product.expects(:add_repo).never
        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        @controller.expects(:sync_task).never
        @controller.create_container_repo_if_needed
      end

      it 'updates hrefs' do
        container_name = "foo"
        container_push_name = "default_org/test/foo"
        latest_version_href = "asdfghjk"
        pulp_repo_href = "repo_href"
        pulp_distribution_href = "distribution_href"
        root_id = 8_675_309
        instance_id = ::Katello::RootRepository.find_by(name: 'busybox').library_instance.id
        content_view_id = 2

        # mock the product, root repo, instance repo, content view
        mock_content_view = mock('content_view')
        mock_content_view.stubs(:id).returns(content_view_id)
        mock_instance_repo = mock('library_instance')
        mock_instance_repo.expects(:update!).with(version_href: latest_version_href)
        mock_instance_repo.stubs(:root_id).returns(root_id)
        mock_instance_repo.stubs(:content_view).returns(mock_content_view)
        mock_instance_repo.stubs(:id).returns(instance_id)
        mock_root_repo = mock('root_repository')
        mock_root_repo.stubs(:library_instance).returns(mock_instance_repo)
        mock_root_repo.stubs(:repository_references).returns([])
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([mock_root_repo])
        mock_product = mock('Product')
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)
        mock_product.expects(:add_repo).never

        # mock the pulp api endpoint
        mock_push_repo_api_response_results = mock('mock_push_repo_api_response_results')
        mock_push_repo_api_response_results.stubs(:latest_version_href).returns(latest_version_href)
        mock_push_repo_api_response_results.stubs(:pulp_href).returns(pulp_repo_href)
        mock_distribution_api_response_results = mock('mock_distribution_api_response_results')
        mock_distribution_api_response_results.stubs(:pulp_href).returns(pulp_distribution_href)

        mock_pulp_api = mock('pulp_api')
        mock_pulp_api.expects(:container_push_repo_for_name).with(container_push_name).returns(mock_push_repo_api_response_results)
        mock_pulp_api.expects(:container_push_distribution_for_repository).with(pulp_repo_href).returns(mock_distribution_api_response_results)

        # mock the repository reference
        mock_repo_reference = mock('repo_reference')
        mock_repo_reference.expects(:create!)

        # set up pulp stubs
        mock_pulp_primary = mock('pulp_primary')
        mock_backend_service = mock('backend_service')
        SmartProxy.stubs(:pulp_primary).returns(mock_pulp_primary)
        #::Katello::Pulp3::Repository.expects(:api).with(mock_pulp_primary, ::Katello::Repository::DOCKER_TYPE).returns(mock_repo_api)
        mock_instance_repo.stubs(:backend_service).with(mock_pulp_primary).returns(mock_backend_service)
        mock_backend_service.stubs(:api).returns(mock_pulp_api)
        ::Katello::Pulp3::RepositoryReference.stubs(:where).with(
          root_repository_id: root_id,
          content_view_id: content_view_id,
          repository_href: pulp_repo_href
        ).returns(mock_repo_reference)

        # set up the controller
        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        @controller.instance_variable_set(:@container_path_input, container_push_name)

        assert @controller.save_push_repo_hrefs
      end

      it 'rejects missing root repo on content indexing' do
        container_name = "foo"

        mock_pulp_api = mock('pulp_api')
        mock_instance_repo = mock('instance repo')
        mock_instance_repo.stubs(:backend_service).returns(mock_pulp_api)
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([])
        mock_product = mock('Product')
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)

        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        expect_render_podman_error("BLOB_UPLOAD_UNKNOWN", :not_found)
        refute @controller.save_push_repo_hrefs
      end

      it 'rejects missing instance repo on content indexing' do
        container_name = "foo"

        mock_root_repo = mock('root_repository')
        mock_root_repo.expects(:library_instance).returns(nil)
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([mock_root_repo])
        mock_product = mock('Product')
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)

        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        expect_render_podman_error("BLOB_UPLOAD_UNKNOWN", :not_found)
        refute @controller.save_push_repo_hrefs
      end

      it 'rejects missing repo api response on content indexing' do
        container_name = "foo"
        container_push_name = "default_org/test/foo"

        mock_instance_repo = mock('library_instance')
        mock_root_repo = mock('root_repository')
        mock_root_repo.stubs(:library_instance).returns(mock_instance_repo)
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([mock_root_repo])
        mock_product = mock('Product')
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)

        mock_pulp_api = mock('pulp_api')
        mock_pulp_api.expects(:container_push_repo_for_name).with(container_push_name).returns(nil)

        mock_pulp_primary = mock('pulp_primary')
        SmartProxy.stubs(:pulp_primary).returns(mock_pulp_primary)
        mock_backend_service = mock('backend_service')
        mock_instance_repo.stubs(:backend_service).with(mock_pulp_primary).returns(mock_backend_service)
        mock_backend_service.stubs(:api).returns(mock_pulp_api)

        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        @controller.instance_variable_set(:@container_path_input, container_push_name)
        expect_render_podman_error("BLOB_UPLOAD_UNKNOWN", :not_found)
        refute @controller.save_push_repo_hrefs
      end

      it 'rejects missing pulp_distribution_href on content indexing' do
        container_name = "foo"
        container_push_name = "default_org/test/foo"
        pulp_repo_href = "repo_href"
        latest_version_href = "latest_version_href"

        mock_instance_repo = mock('library_instance')
        mock_root_repo = mock('root_repository')
        mock_root_repo.stubs(:repository_references).returns(['salmon'])
        mock_root_repo.stubs(:library_instance).returns(mock_instance_repo)
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([mock_root_repo])
        mock_product = mock('Product')
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)

        mock_push_repo_api_response_results = mock('mock_push_repo_api_response_results')
        mock_push_repo_api_response_results.stubs(:latest_version_href).returns(latest_version_href)
        mock_push_repo_api_response_results.stubs(:pulp_href).returns(pulp_repo_href)
        mock_distribution_api_response_results = mock('mock_distribution_api_response_results')
        mock_distribution_api_response_results.stubs(:pulp_href).returns(nil)

        mock_pulp_api = mock('pulp_api')
        mock_pulp_api.expects(:container_push_repo_for_name).with(container_push_name).returns(mock_push_repo_api_response_results)
        mock_pulp_api.expects(:container_push_distribution_for_repository).with(pulp_repo_href).returns(mock_distribution_api_response_results)

        mock_pulp_primary = mock('pulp_primary')
        SmartProxy.stubs(:pulp_primary).returns(mock_pulp_primary)
        mock_backend_service = mock('backend_service')
        mock_instance_repo.expects(:update!).with(version_href: latest_version_href)
        mock_instance_repo.stubs(:backend_service).with(mock_pulp_primary).returns(mock_backend_service)
        mock_backend_service.stubs(:api).returns(mock_pulp_api)

        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        @controller.instance_variable_set(:@container_path_input, container_push_name)
        expect_render_podman_error("BLOB_UPLOAD_UNKNOWN", :not_found)
        refute @controller.save_push_repo_hrefs
      end

      it 'rejects missing latest_version_href on content indexing' do
        container_name = "foo"
        container_push_name = "default_org/test/foo"
        pulp_repo_href = "repo_href"

        mock_instance_repo = mock('library_instance')
        mock_root_repo = mock('root_repository')
        mock_root_repo.stubs(:library_instance).returns(mock_instance_repo)
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([mock_root_repo])
        mock_product = mock('Product')
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)

        mock_push_repo_api_response_results = mock('mock_push_repo_api_response_results')
        mock_push_repo_api_response_results.stubs(:latest_version_href).returns(nil)
        mock_push_repo_api_response_results.stubs(:pulp_href).returns(pulp_repo_href)

        mock_pulp_api = mock('pulp_api')
        mock_pulp_api.expects(:container_push_repo_for_name).with(container_push_name).returns(mock_push_repo_api_response_results)

        mock_pulp_primary = mock('pulp_primary')
        SmartProxy.stubs(:pulp_primary).returns(mock_pulp_primary)
        mock_backend_service = mock('backend_service')
        mock_instance_repo.stubs(:backend_service).with(mock_pulp_primary).returns(mock_backend_service)
        mock_backend_service.stubs(:api).returns(mock_pulp_api)

        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        @controller.instance_variable_set(:@container_path_input, container_push_name)
        expect_render_podman_error("BLOB_UPLOAD_UNKNOWN", :not_found)
        refute @controller.save_push_repo_hrefs
      end

      it 'rejects missing pulp_href on content indexing' do
        container_name = "foo"
        container_push_name = "default_org/test/foo"
        latest_version_href = "asdfghjk"

        mock_instance_repo = mock('library_instance')
        mock_root_repo = mock('root_repository')
        mock_root_repo.stubs(:library_instance).returns(mock_instance_repo)
        mock_root_repositories = mock('root_repositories')
        mock_root_repositories.stubs(:where).with(label: container_name).returns([mock_root_repo])
        mock_product = mock('Product')
        mock_product.stubs(:root_repositories).returns(mock_root_repositories)

        mock_push_repo_api_response_results = mock('mock_push_repo_api_response_results')
        mock_push_repo_api_response_results.stubs(:latest_version_href).returns(latest_version_href)
        mock_push_repo_api_response_results.stubs(:pulp_href).returns(nil)

        mock_pulp_api = mock('pulp_api')
        mock_pulp_api.expects(:container_push_repo_for_name).with(container_push_name).returns(mock_push_repo_api_response_results)

        mock_pulp_primary = mock('pulp_primary')
        SmartProxy.stubs(:pulp_primary).returns(mock_pulp_primary)
        mock_backend_service = mock('backend_service')
        mock_instance_repo.stubs(:backend_service).with(mock_pulp_primary).returns(mock_backend_service)
        mock_backend_service.stubs(:api).returns(mock_pulp_api)

        @controller.instance_variable_set(:@product, mock_product)
        @controller.instance_variable_set(:@container_name, container_name)
        @controller.instance_variable_set(:@container_path_input, container_push_name)
        expect_render_podman_error("BLOB_UPLOAD_UNKNOWN", :not_found)
        refute @controller.save_push_repo_hrefs
      end

      def mock_pulp_response(code, headers)
        mock_response = mock
        mock_response.stubs(:code).returns(code)
        mock_response.stubs(:headers).returns(headers)
        mock_response
      end

      def expect_render_podman_error(error_code, error_status)
        error = @controller.expects(:render_podman_error).with do |code, _message, status|
          code == error_code && status == error_status
        end
        error.returns(false)
      end
    end
    #rubocop:enable Metrics/BlockLength
  end
end
