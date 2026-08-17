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
          :arr_two,
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

    # Regression: bodyless POST must send nil body + real headers, NOT the headers
    # hash smuggled into the payload slot. The old `.compact` produced
    # post({headers}) which serialized headers as an x-www-form-urlencoded body and
    # broke OAuth signing against Candlepin (Redmine #39637).
    def test_post_nil_payload_keeps_headers_as_headers
      headers = { headerOne: 'headerOneValue' }
      mock_response = stub(code: 200, body: '')
      # payload stays nil; headers stay in the headers slot
      RestClient::Resource.any_instance.expects(:post).with(nil, headers).returns(mock_response)
      TestHttpResource.post('/path', nil, headers)
    end

    # Regression: PUT with a nil body behaves the same as POST.
    def test_put_nil_payload_keeps_headers_as_headers
      headers = { headerOne: 'headerOneValue' }
      mock_response = stub(code: 200, body: '')
      RestClient::Resource.any_instance.expects(:put).with(nil, headers).returns(mock_response)
      TestHttpResource.put('/path', nil, headers)
    end

    # Regression: headerless GET must call get({}), never get(nil) (which raises
    # TypeError: no implicit conversion of nil into Hash) and never get(nil, nil)
    # (ArgumentError). This is the Candlepin ping path (get('/candlepin/status')).
    def test_get_no_headers_passes_empty_hash
      mock_response = stub(code: 200, body: '')
      RestClient::Resource.any_instance.expects(:get).with({}).returns(mock_response)
      TestHttpResource.get('/path')
    end

    # Regression: headerless DELETE must call delete({}), not delete(nil).
    def test_delete_no_headers_passes_empty_hash
      mock_response = stub(code: 200, body: '')
      RestClient::Resource.any_instance.expects(:delete).with({}).returns(mock_response)
      TestHttpResource.delete('/path')
    end
  end
end
