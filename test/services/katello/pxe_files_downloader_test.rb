require 'katello_test_helper'

module Katello
  class PxeFilesDownloaderTest < ActiveSupport::TestCase
    def test_fetches_pxe_files
      capsule = SmartProxy.pulp_primary
      repository = FactoryBot.create(
        :katello_repository,
        :with_product,
        distribution_family: 'Red Hat',
        distribution_version: '7.5'
      )
      repository.organization.expects(:debug_cert).returns(
        cert: generate_certificate,
        key: OpenSSL::PKey::RSA.generate(2048))
      downloader = PxeFilesDownloader.new(repository, capsule)

      downloader.expects(:fetch).twice
      downloader.download_files
    end

    private

    def generate_certificate
      key = OpenSSL::PKey::RSA.new(1024)
      public_key = key.public_key

      subject = "/C=BE/O=Test/OU=Test/CN=Test"

      cert = OpenSSL::X509::Certificate.new
      cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60
      cert.public_key = public_key
      cert.serial = 0x0
      cert.version = 2

      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = cert
      cert.extensions = [
        ef.create_extension("basicConstraints", "CA:TRUE", true),
        ef.create_extension("subjectKeyIdentifier", "hash")
        # ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
      ]
      cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                             "keyid:always,issuer:always")

      cert.sign key, OpenSSL::Digest.new('SHA256')

      cert.to_pem
    end
  end
end
