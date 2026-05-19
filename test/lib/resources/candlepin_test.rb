require 'katello_test_helper'

module Katello
  module Resources
    module Candlepin
      class UpstreamCandlepinResourceTest < ActiveSupport::TestCase
        def test_upstream_consumer_nil_current_organization
          Organization.stubs(:current).returns(nil)
          UpstreamCandlepinResource.upstream_consumer
          flunk("Failed to raise exception when current organization is nil.")
        rescue RuntimeError => e
          assert_equal(e.message, "Current organization not set.", "Invalid message: #{e.message}")
        end

        def test_upstream_consumer_current_organization_no_imported_manifest
          Organization.stubs(:current).returns(stub(owner_details: {}))

          assert_raises(Katello::Errors::NoManifestImported) do
            UpstreamCandlepinResource.upstream_consumer
          end
        end

        def test_global_proxy_nil
          Setting[:content_default_http_proxy] = nil
          assert_nil UpstreamCandlepinResource.proxy_uri
        end

        def test_global_proxy
          ForemanTasks.stubs(:async_task) #prevent global proxy setting callback
          proxy = FactoryBot.create(:http_proxy, :url => 'http://foo.com:1000', :username => 'admin', :password => 'password')
          Setting[:content_default_http_proxy] = proxy.name

          assert_equal 'proxy://admin:password@foo.com:1000', UpstreamCandlepinResource.proxy_uri
        end

        def test_global_proxy_no_cacert
          proxy = FactoryBot.create(:http_proxy, :url => 'http://foo.com:1000',
                                    :username => 'admin',
                                    :password => 'password',
                                    :cacert => "")
          UpstreamCandlepinResource.stubs(:proxy).returns(proxy)
          Foreman::Util.expects(:add_ca_bundle_to_store).never
          OpenSSL::X509::Certificate.expects(:new)
          OpenSSL::PKey::RSA.expects(:new)
          UpstreamCandlepinResource.resource(url: "http://www.foo.com", client_cert: "", client_key: "")
        end

        def test_default_headers_excludes_cp_user_and_cp_consumer
          User.stubs(:cp_oauth_header).returns({'cp-user' => 'admin'})

          headers = UpstreamCandlepinResource.default_headers

          refute headers.key?('cp-user'), "UpstreamCandlepinResource should not include 'cp-user' header"
          refute headers.key?('cp-consumer'), "UpstreamCandlepinResource should not include 'cp-consumer' header"

          assert headers.key?('accept'), "Headers should still include 'accept'"
          assert headers.key?('content-type'), "Headers should still include 'content-type'"
        end

        def test_default_headers_excludes_cp_consumer_with_uuid
          User.stubs(:consumer?).returns(true)
          User.stubs(:cp_oauth_header).returns({'cp-consumer' => 'test-uuid'})

          headers = UpstreamCandlepinResource.default_headers('hypervisor-uuid')

          refute headers.key?('cp-user'), "UpstreamCandlepinResource should not include 'cp-user' header"
          refute headers.key?('cp-consumer'), "UpstreamCandlepinResource should not include 'cp-consumer' header even with uuid parameter"

          assert headers.key?('accept'), "Headers should still include 'accept'"
          assert headers.key?('content-type'), "Headers should still include 'content-type'"
        end

        def test_site_preserves_non_default_port
          UpstreamCandlepinResource.stubs(:upstream_api_uri).returns(URI.parse('https://cdn.example.com:8443/subscription'))

          assert_equal 'https://cdn.example.com:8443', UpstreamCandlepinResource.site
        end
      end

      class UpstreamConsumerPingTest < ActiveSupport::TestCase
        def setup
          @mock_response = stub(status: 200, body: '', headers: {})
          UpstreamConsumer.stubs(:issue_request).returns(@mock_response)
        end

        def test_ping_success
          response = UpstreamConsumer.ping
          assert_equal 200, response.status
        end

        def test_ping_401_raises_gone
          @mock_response.stubs(:status).returns(401)
          assert_raises(Katello::Errors::UpstreamConsumerGone) { UpstreamConsumer.ping }
        end

        def test_ping_410_raises_gone
          @mock_response.stubs(:status).returns(410)
          assert_raises(Katello::Errors::UpstreamConsumerGone) { UpstreamConsumer.ping }
        end

        def test_ping_404_raises_not_found
          @mock_response.stubs(:status).returns(404)
          assert_raises(Katello::Errors::UpstreamConsumerNotFound) { UpstreamConsumer.ping }
        end
      end

      class CandlepinResourceTest < ActiveSupport::TestCase
        def test_default_headers_includes_cp_oauth_header
          User.stubs(:cp_oauth_header).returns({'cp-user' => 'admin'})

          headers = CandlepinResource.default_headers

          assert headers.key?('cp-user'), "CandlepinResource should include 'cp-user' header for local Candlepin"
          assert_equal 'admin', headers['cp-user']
        end
      end

      class ConsumerGetUrlTest < ActiveSupport::TestCase
        def setup
          SETTINGS.stubs(:dig).returns(nil)
          SETTINGS[:katello] = { candlepin: { bulk_load_size: 100 } }
          stub_request(:any, /.*/)
            .to_return(body: '[]', headers: { 'Content-Type' => 'application/json' })
        end

        def test_get_with_owner_and_include_only
          Consumer.get('owner' => 'acme', :include_only => [:uuid], :sort_by => 'uuid')
          first_request = WebMock::RequestRegistry.instance.requested_signatures.hash.keys.first
          url = first_request.uri.to_s
          assert_match %r{/candlepin/consumers\?}, url, "URL should start query string with ?"
          assert_match(/owner=acme/, url)
          assert_match(/include=uuid/, url)
          assert_match(/per_page=/, url)
          refute_match(/consumers&/, url, "Should not have bare & after path")
        end

        def test_get_with_include_only_and_no_other_params
          Consumer.get(:include_only => [:uuid])
          first_request = WebMock::RequestRegistry.instance.requested_signatures.hash.keys.first
          url = first_request.uri.to_s
          assert_match %r{/candlepin/consumers\?}, url, "URL should start query string with ?"
          assert_match(/include=uuid/, url)
          refute_match(/consumers&include/, url, "Should not have bare & before include")
        end

        def test_get_with_string_param_returns_single_consumer
          stub_request(:get, /.*/)
            .to_return(body: { 'uuid' => 'abc-123', 'name' => 'test' }.to_json,
                       headers: { 'Content-Type' => 'application/json' })
          result = Consumer.get('abc-123')
          assert_equal 'abc-123', result['uuid']
        end
      end

      class ContentOverridesEdgeCaseTest < ActiveSupport::TestCase
        def test_consumer_update_content_overrides_empty_array
          result = Consumer.update_content_overrides('test-uuid', [])
          assert_empty result
        end

        def test_activation_key_update_content_overrides_empty_array
          result = ActivationKey.update_content_overrides('test-ak-id', [])
          assert_empty result
        end

        def test_activation_key_update_content_overrides_empty_response_body
          ActivationKey.stubs(:default_headers).returns({})
          Candlepin::CandlepinResource.expects(:issue_request).returns(stub(body: ''))

          result = ActivationKey.update_content_overrides('test-ak-id', [{ name: 'repo-1', value: nil }])

          assert_empty result
        end
      end

      class ProductTest < ActiveSupport::TestCase
        def setup
        end

        def test_create_unlimited_subsciption
          product_id = 3
          owner = Organization.first
          start_date = Time.parse('2020-01-10 07:07:47 +0000')
          end_date = Time.parse('2049-12-01 00:00:00 +0000')
          expected_pool = {
            'startDate' => start_date,
            'endDate' => end_date,
            'quantity' => -1,
            'accountNumber' => '',
            'productId' => product_id,
            'providedProducts' => [],
            'contractNumber' => '',
          }

          ::Katello::Resources::Candlepin::Pool.expects(:create).with(owner.label, expected_pool).returns('{}')
          ::Katello::Resources::Candlepin::Product.create_unlimited_subscription(owner.label, product_id, start_date)
        end
      end
    end
  end
end
