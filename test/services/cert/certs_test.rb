require 'katello_test_helper'

module Katello
  class CertMappingTest < ActiveSupport::TestCase
    def test_cert_mapping
      cert = File.read(File.join(Katello::Engine.root, "test/fixtures/certs/real-cert.crt"))
      assert_equal({ "1.2.840.113549.1.1.1" => "rsaEncryption" }, Cert::Certs.cert_mapping(cert))

      # commenting this out since seems to be failing in CI due to OpenSSL version being too low. Passes locally.
      # pqc_cert = File.read(File.join(Katello::Engine.root, "test/fixtures/certs/real-ml-dsa-65-cert.crt"))
      # assert_equal({ "2.16.840.1.101.3.4.3.18" => "ML-DSA-65" }, Cert::Certs.cert_mapping(pqc_cert))
    end

    # commenting this out since seems to be failing in CI due to OpenSSL version being too low. Passes locally.
    # def test_cert_mapping_uses_the_ml_dsa_long_name
    #   ml_dsa_subject_public_key_info = OpenSSL::ASN1::Sequence.new([
    #                                                                  OpenSSL::ASN1::Sequence.new([
    #                                                                                                OpenSSL::ASN1::ObjectId.new("2.16.840.1.101.3.4.3.17"),
    #                                                                                              ]),
    #                                                                  OpenSSL::ASN1::BitString.new(""),
    #                                                                ]).to_der
    #   OpenSSL::PKey::RSA.any_instance.expects(:public_to_der).returns(ml_dsa_subject_public_key_info)

    #   cert = File.read(File.join(Katello::Engine.root, "test/fixtures/certs/real-cert.crt"))
    #   assert_equal({ "2.16.840.1.101.3.4.3.17" => "ML-DSA-44" }, Cert::Certs.cert_mapping(cert))
    # end
  end

  class CertsTest < ActiveSupport::TestCase
    include VCR::TestCase

    def setup
      @org = get_organization
      Resources::Candlepin::Owner.create(@org.label, @org.name)
      @original_ssl_ca_file = SETTINGS[:katello][:candlepin][:ca_cert_file]
    end

    def teardown
      Resources::Candlepin::Owner.destroy(@org.label)
      SETTINGS[:katello][:candlepin][:ca_cert_file] = @original_ssl_ca_file
    end

    def test_verify_ueber_cert_no_change
      store = OpenSSL::X509::Store.new
      OpenSSL::X509::Store.stubs(:new).returns(store)
      store.expects(:add_file).with(@original_ssl_ca_file).returns
      store.expects(:verify).returns(true)
      @org.expects(:regenerate_ueber_cert).never
      Cert::Certs.verify_ueber_cert(@org)
    end

    def test_verify_ueber_cert_changes
      SETTINGS[:katello][:candlepin][:ca_cert_file] = File.join("#{Katello::Engine.root}", "/ca/redhat-uep.pem")
      @org.expects(:regenerate_ueber_cert).once
      Cert::Certs.verify_ueber_cert(@org)
    end
  end
end
