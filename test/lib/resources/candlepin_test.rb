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
            'contractNumber' => ''
          }

          ::Katello::Resources::Candlepin::Pool.expects(:create).with(owner.label, expected_pool).returns('{}')
          ::Katello::Resources::Candlepin::Product.create_unlimited_subscription(owner.label, product_id, start_date)
        end
      end
    end
  end
end
