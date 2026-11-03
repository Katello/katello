require 'minitest/autorun'
require 'minitest/mock'
require_relative 'pqc_support'

class PqcSupportTest < Minitest::Test
  include Katello::PqcSupport

  def test_supported_algorithm_runs
    oid = Struct.new(:ln).new('ML-DSA-65')
    OpenSSL::PKey.stub(:generate_key, Object.new) do
      OpenSSL::ASN1::ObjectId.stub(:new, oid) do
        assert_nil pqc_required
      end
    end
  end

  def test_missing_algorithm_skips_in_optional_environment
    with_pqc_required(nil) do
      without_ml_dsa do
        assert_raises(Minitest::Skip) { pqc_required }
      end
    end
  end

  def test_missing_algorithm_fails_in_required_environment
    with_pqc_required('true') do
      without_ml_dsa do
        assert_raises(Minitest::Assertion) { pqc_required }
      end
    end
  end

  def test_unrecognized_algorithm_name_skips
    oid = Struct.new(:ln).new(nil)
    with_pqc_required(nil) do
      OpenSSL::PKey.stub(:generate_key, Object.new) do
        OpenSSL::ASN1::ObjectId.stub(:new, oid) do
          assert_raises(Minitest::Skip) { pqc_required }
        end
      end
    end
  end

  private

  def without_ml_dsa(&block)
    unavailable = ->(*) { raise OpenSSL::PKey::PKeyError, 'unsupported algorithm' }
    OpenSSL::PKey.stub(:generate_key, unavailable, &block)
  end

  def with_pqc_required(value)
    original = ENV['PQC_REQUIRED']
    ENV['PQC_REQUIRED'] = value
    yield
  ensure
    ENV['PQC_REQUIRED'] = original
  end
end
