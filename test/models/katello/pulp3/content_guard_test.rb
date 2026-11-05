require 'katello_test_helper'

module Katello
  module Pulp3
    class ContentGuardTest < ActiveSupport::TestCase
      it 'updates the existing row by name instead of blindly creating a duplicate' do
        existing = Katello::Pulp3::ContentGuard.create!(name: 'RHSMCertGuard', pulp_href: '/old-href/')
        found = OpenStruct.new(name: 'RHSMCertGuard', pulp_href: '/new-href/')
        api = mock
        api.stubs(:list).returns(OpenStruct.new(results: [found]))
        Katello::Pulp3::Api::ContentGuard.stubs(:new).returns(api)

        Katello::Pulp3::ContentGuard.import(SmartProxy.pulp_primary!, true)

        assert_equal 1, Katello::Pulp3::ContentGuard.where(name: 'RHSMCertGuard').count
        assert_equal '/new-href/', existing.reload.pulp_href
      end

      it 'creates when no row exists yet for that name' do
        found = OpenStruct.new(name: 'RHSMCertGuard', pulp_href: '/href/')
        api = mock
        api.stubs(:list).returns(OpenStruct.new(results: [found]))
        Katello::Pulp3::Api::ContentGuard.stubs(:new).returns(api)

        Katello::Pulp3::ContentGuard.import(SmartProxy.pulp_primary!, true)

        assert Katello::Pulp3::ContentGuard.exists?(name: 'RHSMCertGuard', pulp_href: '/href/')
      end
    end
  end
end
