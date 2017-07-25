require 'katello_test_helper'

module Katello
  describe ::Actions::Candlepin::ImportPoolHandler do
    let(:pool_id) { 'abc123' }
    let(:pool) { OpenStruct.new(:id => pool_id) }
    let(:pool_two) { katello_pools(:pool_two) }
    let(:subscription_facet) { katello_subscription_facets(:one) }

    before do
      ::Katello::Pool.stubs(:search).returns([pool])
      ::Katello::Pool.any_instance.stubs(:import_data).returns(true)
      ::Katello::Candlepin::MessageHandler.any_instance.stubs(:get_pool_by_reference_id).returns(pool_two)
      ::Katello::Candlepin::MessageHandler.any_instance.stubs(:subscription_facet).returns(subscription_facet)
    end

    def message(subject, content = {})
      result = {:subject => subject }
      result[:content] = JSON.generate(content)
      OpenStruct.new(result)
    end

    describe 'handles entitlement.created' do
      let(:mymessage) do
        message("entitlement.created", :referenceId => pool_id)
      end

      it 'reindex the pool' do
        ::Actions::Candlepin::ImportPoolHandler.new(Rails.logger).handle(mymessage)
      end
    end

    describe 'handles entitlement.deleted' do
      let(:mymessage) do
        message("entitlement.deleted", :referenceId => pool_id)
      end

      it 'reindex the pool' do
        ::Actions::Candlepin::ImportPoolHandler.new(Rails.logger).handle(mymessage)
      end
    end

    describe 'handles pool.created' do
      let(:mymessage) do
        message "pool.created", :entityId => pool_id
      end

      it 'adds pool to index and reindex the pool' do
        ::Actions::Candlepin::ImportPoolHandler.new(Rails.logger).handle(mymessage)
      end
    end

    describe 'handles pool.deleted' do
      let(:mymessage) do
        message "pool.deleted", :entityId => pool_id
      end

      it 'pool removed from index' do
        ::Actions::Candlepin::ImportPoolHandler.new(Rails.logger).handle(mymessage)
      end
    end
  end
end
