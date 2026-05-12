require 'katello_test_helper'

module Katello
  class HttpResourceTest < ActiveSupport::TestCase
    class TestHttpResource < HttpResource
      self.site = 'http://localhost'
      def self.logger
        Rails.logger
      end
    end

    def setup
      @mock_response = stub(status: 200, body: '', headers: {})
      @mock_conn = stub
      TestHttpResource.stubs(:faraday_connection).returns(@mock_conn)
    end

    def test_query_string_empty_hash
      assert_equal '', TestHttpResource.query_string({})
    end

    def test_query_string_empty_array
      assert_equal '', TestHttpResource.query_string([])
    end

    def test_query_string_nil
      assert_equal '', TestHttpResource.query_string(nil)
    end

    def test_query_string_hash
      params = { foo: 'fru', bar: 'bru', arr: [:arr_one, :arr_two] }
      result = TestHttpResource.query_string(params)
      assert_equal "?foo=fru&bar=bru&arr=arr_one&arr=arr_two", result
    end

    def test_query_string_array_of_tuples
      params = [[:poolid, 'abc'], [:poolid, 'def'], [:include, 'id']]
      result = TestHttpResource.query_string(params)
      assert_equal "?poolid=abc&poolid=def&include=id", result
    end

    def test_hash_to_query_alias
      assert_equal "?foo=bar", TestHttpResource.hash_to_query(foo: 'bar')
    end

    def test_get
      @mock_conn.expects(:send).with(:get, '/path').yields(stub_request).returns(@mock_response)
      TestHttpResource.get('/path', headers: { 'headerOne' => 'headerOneValue' })
    end

    def test_get_no_headers
      @mock_conn.expects(:send).with(:get, '/path').yields(stub_request).returns(@mock_response)
      TestHttpResource.get('/path')
    end

    def test_get_with_params
      @mock_conn.expects(:send).with(:get, '/path?foo=bar').yields(stub_request).returns(@mock_response)
      TestHttpResource.get('/path', params: { foo: 'bar' })
    end

    def test_delete
      @mock_conn.expects(:send).with(:delete, '/path').yields(stub_request).returns(@mock_response)
      TestHttpResource.delete('/path', headers: { 'headerOne' => 'headerOneValue' })
    end

    def test_put
      @mock_conn.expects(:send).with(:put, '/path').yields(stub_request).returns(@mock_response)
      TestHttpResource.put('/path', { payloadKey: 'payloadValue' }, headers: { 'headerOne' => 'headerOneValue' })
    end

    def test_post
      @mock_conn.expects(:send).with(:post, '/path').yields(stub_request).returns(@mock_response)
      TestHttpResource.post('/path', { payloadKey: 'payloadValue' }, headers: { 'headerOne' => 'headerOneValue' })
    end

    def test_process_response_success
      response = stub(status: 200, body: '{"result": "ok"}')
      result = TestHttpResource.process_response(response)
      assert_equal response, result
    end

    def test_process_response_error
      response = stub(status: 404, body: '{"displayMessage": "Not found"}')
      error = assert_raises(HttpResource::HttpError) do
        TestHttpResource.process_response(response)
      end
      assert_equal '404', error.code
      assert_equal 'Not found', error.message
      assert_equal '{"displayMessage": "Not found"}', error.response_body
    end

    private

    def stub_request
      req = stub
      req.stubs(:headers).returns({})
      req.stubs(:body=)
      req
    end
  end
end
