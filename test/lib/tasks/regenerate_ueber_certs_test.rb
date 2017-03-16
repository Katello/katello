require 'katello_test_helper'
require 'support/candlepin/owner_support'
require 'rake'

module Katello
  class RegenerateUeberCertsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/regenerate_ueber_certs'
      Rake::Task['katello:regenerate_ueber_certs'].reenable
      Rake::Task.define_task(:environment)
      VCR.insert_cassette('lib/tasks/regenerate_ueber_certs')
      @org = get_organization
      Resources::Candlepin::Owner.create(@org.label, @org.name)
    end

    def teardown
      Resources::Candlepin::Owner.destroy(@org.label)
      VCR.eject_cassette
    end

    def test_regenerate_ueber_certs
      ::Katello::Resources::Candlepin::Owner.expects(:generate_ueber_cert).times(Organization.all.count)
      Rake::Task["katello:regenerate_ueber_certs"].invoke
    end

    def test_regenerate_ueber_certs_one_org
      before = Organization.find(@org).debug_cert
      Rake::Task["katello:regenerate_ueber_certs"].invoke("#{@org.label}")
      after = Organization.find(@org).debug_cert
      refute before == after
    end
  end
end
