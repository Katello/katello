require 'minitest/autorun'
require_relative '../../../lib/monkeys/pulp_file_sync_optimize'

class PulpFileSyncOptimizeTest < Minitest::Test
  ERROR_BODY = '{"optimize":["Unexpected field"]}'.freeze
  REQUEST = {remote: '/pulp/api/v3/remotes/file/file/test/', mirror: true}.freeze

  class Transport
    attr_reader :calls

    def initialize(*responses)
      @responses = responses
      @calls = []
    end

    def sync_with_http_info(href, data, opts = {})
      @calls << [href, data, opts]
      response = @responses.shift
      fail response if response.is_a?(Exception)
      response
    end
  end

  class PatchedTransport < Transport
    prepend PulpFileSyncOptimizeCompatibility
  end

  def error(code = 400, body = ERROR_BODY)
    PulpFileClient::ApiError.new(code: code, response_body: body)
  end

  [true, false].each do |value|
    define_method("test_retries_explicit_#{value}_without_mutation") do
      request = REQUEST.merge(optimize: value).freeze
      opts = {header_params: {'X-Test' => 'preserved'}}
      result = [Object.new, 202, {}]
      api = PatchedTransport.new(error, result)
      assert_same result, api.sync_with_http_info('/repo/', request, opts)
      assert_equal [['/repo/', request, opts], ['/repo/', REQUEST, opts]], api.calls
      assert_equal value, request[:optimize]
    end

    define_method("test_supported_target_keeps_#{value}") do
      request = REQUEST.merge(optimize: value)
      result = [Object.new, 202, {}]
      api = PatchedTransport.new(result)
      assert_same result, api.sync_with_http_info('/repo/', request)
      assert_equal [['/repo/', request, {}]], api.calls
    end
  end

  def test_accepts_model_and_string_keys
    data = REQUEST.merge(optimize: false).transform_keys(&:to_s)
    model_class = Struct.new(:attributes) do
      def to_hash
        attributes
      end
    end
    model = model_class.new(data)
    api = PatchedTransport.new(error, :success)
    assert_equal :success, api.sync_with_http_info('/repo/', model)
    refute api.calls.last[1].key?('optimize')
    assert_same false, model.to_hash['optimize']
  end

  def test_retry_failure_propagates_without_loop
    second_error = error
    api = PatchedTransport.new(error, second_error)
    assert_same second_error, assert_raises(PulpFileClient::ApiError) {
      api.sync_with_http_info('/repo/', REQUEST.merge(optimize: true))
    }
    assert_equal 2, api.calls.size
  end

  def test_no_retry_when_field_was_not_sent
    first_error = error
    api = PatchedTransport.new(first_error)
    assert_same first_error, assert_raises(PulpFileClient::ApiError) {
      api.sync_with_http_info('/repo/', REQUEST)
    }
    assert_equal 1, api.calls.size
  end

  def test_unrelated_errors_are_not_masked
    [[500, ERROR_BODY], [401, ERROR_BODY],
     [400, '{"remote":["Invalid"]}'],
     [400, '{"optimize":["Invalid boolean"]}'],
     [400, '{"optimize":["Unexpected field"],"remote":["Invalid"]}'],
     [400, 'not json'], [400, 'null'], [400, '[]'], [400, nil]].each do |code, body|
      original_error = error(code, body)
      api = PatchedTransport.new(original_error)
      assert_same original_error, assert_raises(PulpFileClient::ApiError) {
        api.sync_with_http_info('/repo/', REQUEST.merge(optimize: false))
      }
      assert_equal 1, api.calls.size
    end
  end

  def test_debug_body_is_not_retried_unchanged
    api = PatchedTransport.new(error)
    assert_raises(PulpFileClient::ApiError) do
      api.sync_with_http_info('/repo/', REQUEST.merge(optimize: true), debug_body: '{}')
    end
    assert_equal 1, api.calls.size
  end
end
