require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      class Repository
        class AptTest < ::ActiveSupport::TestCase
          include Katello::Pulp3Support

          def setup
            @repo = katello_repositories(:debian_9_amd64)
            @proxy = SmartProxy.pulp_primary
          end

          def teardown
            ensure_creatable(@repo, @proxy)
          end

          def test_remote_options
            @repo.root.url = "http://foo.com/bar/"
            service = Katello::Pulp3::Repository::Apt.new(@repo, @proxy)
            assert_equal "http://foo.com/bar/", service.remote_options[:url]
          end

          def test_delete_version_zero
            service = Katello::Pulp3::Repository::Apt.new(@repo, @proxy)
            @repo.version_href = '/pulp/api/v3/repositories/deb/apt/22c9e84b-f49c-4c70-9b4c-49e8c041220f/versions/0/'
            refute service.delete_version
          end

          def test_delete_version
            PulpDebClient::RepositoriesAptVersionsApi.any_instance.expects(:delete).returns({})
            service = Katello::Pulp3::Repository::Apt.new(@repo, @proxy)
            @repo.version_href = '/pulp/api/v3/repositories/deb/apt/22c9e84b-f49c-4c70-9b4c-49e8c041220f/versions/1/'
            assert service.delete_version
          end

          def test_common_remote_options
            service = Katello::Pulp3::Repository::Apt.new(@repo, @proxy)
            @repo.root.upstream_username = 'foo'
            @repo.root.upstream_password = 'bar'

            assert_equal 'foo', service.common_remote_options[:username]
            assert_equal 'bar', service.common_remote_options[:password]

            @repo.root.upstream_username = ''
            @repo.root.upstream_password = ''

            assert_nil service.common_remote_options[:username]
            assert_nil service.common_remote_options[:password]
          end

          def test_publication_options_wo_signing_service
            signing_service_response_list = mock
            signing_service_response_list.expects(:results).returns([])
            PulpcoreClient::SigningServicesApi
              .any_instance
              .expects(:list)
              .with(name: 'katello_deb_sign')
              .returns(signing_service_response_list)
            service = Katello::Pulp3::Repository::Apt.new(@repo, @proxy)
            repo = mock
            repo.expects(:version_href).returns(1)

            pub_opts = service.publication_options(repo)
            assert_nil pub_opts[:simple]
            assert_nil pub_opts[:structured]
            refute pub_opts[:signing_service]
          end

          def test_publication_options_with_signing_service
            signing_service = mock
            signing_service.expects(:pulp_href).returns('signing_service_url')
            signing_service_response_list = mock
            signing_service_response_list.expects(:results).returns([signing_service])

            PulpcoreClient::SigningServicesApi
              .any_instance
              .expects(:list)
              .with(name: 'katello_deb_sign')
              .returns(signing_service_response_list)
            service = Katello::Pulp3::Repository::Apt.new(@repo, @proxy)

            repo = mock
            repo.expects(:version_href).returns(1)

            pub_opts = service.publication_options(repo)
            assert_nil pub_opts[:simple]
            assert_nil pub_opts[:structured]
            assert pub_opts[:signing_service]
          end
        end

        class AptVcrTest < ::ActiveSupport::TestCase
          include Katello::Pulp3Support

          def setup
            @repo = katello_repositories(:debian_9_amd64)
            @proxy = SmartProxy.pulp_primary
            @service = Katello::Pulp3::Repository::Apt.new(@repo, @proxy)
          end

          def teardown
            ensure_creatable(@repo, @proxy)
          end

          def test_create_remote_with_http_proxy_creds
            @service.stubs(:generate_backend_object_name).returns("#{@repo.name}-test")
            HttpProxy.find_by(name: "myhttpproxy").update(username: 'username', password: 'password')
            @repo.root.update(http_proxy_policy: ::Katello::RootRepository::USE_SELECTED_HTTP_PROXY)
            @repo.root.update(http_proxy: HttpProxy.find_by(name: "myhttpproxy"))

            remote_file_data = @service.api.remote_class.new(@service.remote_options)
            remote_response = @service.api.remotes_api.create(remote_file_data)
            @service.delete_remote(href: remote_response.pulp_href)
          end
        end
      end
    end
  end
end
