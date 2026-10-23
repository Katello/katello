require 'katello_test_helper'

module Katello
  module Pulp3
    module Api
      class ContentGuardTest < ActiveSupport::TestCase
        let(:service) { ::Katello::Pulp3::Api::ContentGuard.new(::SmartProxy.pulp_primary) }

        it 'does not write to pulp when a matching guard already exists' do
          found = OpenStruct.new(pulp_href: '/href/', ca_certificate: 'cert', prn: 'prn')
          service.stubs(:ca_cert).returns('cert')
          service.stubs(:list).returns(OpenStruct.new(results: [found]))
          service.expects(:create).never
          service.expects(:partial_update).never
          service.stubs(:persist_if_needed)

          assert_equal found, service.refresh
        end

        it 'only calls partial_update when the found guard cert differs' do
          found = OpenStruct.new(pulp_href: '/href/', ca_certificate: 'old-cert', prn: 'prn')
          service.stubs(:ca_cert).returns('new-cert')
          service.stubs(:list).returns(OpenStruct.new(results: [found]))
          service.expects(:partial_update).with('/href/')
          service.expects(:create).never
          service.stubs(:persist_if_needed)

          service.refresh
        end

        it 'creates when no guard exists yet' do
          service.stubs(:list).returns(OpenStruct.new(results: []))
          created = OpenStruct.new(pulp_href: '/new-href/', prn: 'prn')
          service.expects(:create).returns(created)
          service.expects(:partial_update).never
          service.stubs(:persist_if_needed)

          assert_equal created, service.refresh
        end

        it 'recovers when a concurrent caller wins the local persist race' do
          content_guard_obj = OpenStruct.new(pulp_href: '/href/', prn: 'prn')
          winner = Katello::Pulp3::ContentGuard.new(name: service.default_name, pulp_href: '/href/', pulp_prn: 'prn')
          Katello::Pulp3::ContentGuard.stubs(:find_by).with(:name => service.default_name).returns(nil, winner)
          Katello::Pulp3::ContentGuard.expects(:create!).raises(ActiveRecord::RecordNotUnique.new('duplicate key'))
          winner.expects(:update).with(pulp_href: '/href/', pulp_prn: 'prn')

          service.send(:persist_if_needed, content_guard_obj)
        end
      end
    end
  end
end
