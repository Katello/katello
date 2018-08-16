require 'katello_test_helper'
require 'support/candlepin/owner_support'

module Katello
  class CertsTest < ActiveSupport::TestCase
    def setup
      VCR.insert_cassette('lib/tasks/verify_ueber_cert')
      @org = get_organization
      Resources::Candlepin::Owner.create(@org.label, @org.name)
      @original_ssl_ca_file = Setting[:ssl_ca_file]
    end

    def teardown
      Resources::Candlepin::Owner.destroy(@org.label)
      VCR.eject_cassette
      Setting[:ssl_ca_file] = @original_ssl_ca_file
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
      Setting[:ssl_ca_file] = File.join("#{Katello::Engine.root}", "/ca/redhat-uep.pem")
      @org.expects(:regenerate_ueber_cert).once
      Cert::Certs.verify_ueber_cert(@org)
      Setting[:ssl_ca_file] = @original_ssl_ca_file
    end
  end
end
