require 'katello_test_helper'

module Katello
  class HttpResourceTest < ActiveSupport::TestCase
    class TestHttpResource < HttpResource
      self.site = 'http://localhost'
      def self.logger
        Rails.logger
      end
    end

    def test_hash_to_query_empty
      params = {}

      result = TestHttpResource.hash_to_query(params)

      assert_equal "?", result
    end

    def test_hash_to_query
      params = {
        foo: 'fru',
        bar: 'bru',
        too: 'tru',
        arr: [
          :arr_one,
          :arr_two
        ],
      }

      result = TestHttpResource.hash_to_query(params)

      assert_equal "?foo=fru&bar=bru&too=tru&arr=arr_one&arr=arr_two", result
    end

    def test_get
      headers = { headerOne: 'headerOneValue' }
      mock_response = stub(code: 200, body: '')
      RestClient::Resource.any_instance.expects(:get).with(headers).returns(mock_response)
      TestHttpResource.get('/path', headers)
    end

    def test_get_no_headers
      mock_response = stub(code: 200, body: '')
      RestClient::Resource.any_instance.expects(:get).returns(mock_response)
      TestHttpResource.get('/path')
    end

    def test_delete
      headers = { headerOne: 'headerOneValue' }
      mock_response = stub(code: 200, body: '')
      RestClient::Resource.any_instance.expects(:delete).with(headers).returns(mock_response)
      TestHttpResource.delete('/path', headers)
    end

    def test_put
      headers = { headerOne: 'headerOneValue' }
      payload = { payloadKey: 'payloadValue' }
      mock_response = stub(code: 200, body: '')
      RestClient::Resource.any_instance.expects(:put).with(payload, headers).returns(mock_response)
      TestHttpResource.put('/path', payload, headers)
    end

    def test_post
      headers = { headerOne: 'headerOneValue' }
      payload = { payloadKey: 'payloadValue' }
      mock_response = stub(code: 200, body: '')
      RestClient::Resource.any_instance.expects(:post).with(payload, headers).returns(mock_response)
      TestHttpResource.post('/path', payload, headers)
    end
  end
end
