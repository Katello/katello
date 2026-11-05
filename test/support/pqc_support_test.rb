require 'minitest/autorun'
require 'minitest/mock'
require_relative 'pqc_support'

class PqcSupportTest < Minitest::Test
  include Katello::PqcSupport

  def test_supported_algorithm_runs
    stub(:pqc_supported?, true) do
      assert_nil pqc_required
    end
  end

  def test_missing_algorithm_skips_in_optional_environment
    with_pqc_required(nil) do
      stub(:pqc_supported?, false) do
        assert_raises(Minitest::Skip) { pqc_required }
      end
    end
  end

  def test_missing_algorithm_fails_in_required_environment
    with_pqc_required('true') do
      stub(:pqc_supported?, false) do
        assert_raises(Minitest::Assertion) { pqc_required }
      end
    end
  end

  def test_missing_key_generation_api_skips
    with_pqc_required(nil) do
      OpenSSL::PKey.stub(:respond_to?, false) do
        assert_raises(Minitest::Skip) { pqc_required }
      end
    end
  end

  def test_missing_key_generation_api_fails_in_required_environment
    with_pqc_required('true') do
      OpenSSL::PKey.stub(:respond_to?, false) do
        assert_raises(Minitest::Assertion) { pqc_required }
      end
    end
  end

  private

  def with_pqc_required(value)
    original = ENV['PQC_REQUIRED']
    ENV['PQC_REQUIRED'] = value
    yield
  ensure
    ENV['PQC_REQUIRED'] = original
  end
end
