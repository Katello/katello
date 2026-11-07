require 'katello_test_helper'

class PqcSupportTest < Minitest::Test
  include Katello::PqcSupport

  def test_supported_algorithm_runs
    stubs(:pqc_supported?).with('ML-DSA-65').returns(true)
    assert_nil pqc_required
  end

  def test_missing_algorithm_skips_in_optional_environment
    with_pqc_required(nil) do
      stubs(:pqc_supported?).with('ML-DSA-65').returns(false)
      assert_raises(Minitest::Skip) { pqc_required }
    end
  end

  def test_missing_algorithm_fails_in_required_environment
    with_pqc_required('true') do
      stubs(:pqc_supported?).with('ML-DSA-65').returns(false)
      assert_raises(Minitest::Assertion) { pqc_required }
    end
  end

  def test_missing_key_generation_api_skips
    with_pqc_required(nil) do
      OpenSSL::PKey.expects(:respond_to?).with(:generate_key).returns(false)
      assert_raises(Minitest::Skip) { pqc_required }
    end
  end

  def test_missing_key_generation_api_fails_in_required_environment
    with_pqc_required('true') do
      OpenSSL::PKey.expects(:respond_to?).with(:generate_key).returns(false)
      assert_raises(Minitest::Assertion) { pqc_required }
    end
  end

  private

  def with_pqc_required(value)
    original = ENV['PQC_ENABLED']
    ENV['PQC_ENABLED'] = value
    yield
  ensure
    ENV['PQC_ENABLED'] = original
  end
end
