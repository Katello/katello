require 'katello_test_helper'

module Katello
  describe ::Actions::Candlepin::ReindexPoolSubscriptionHandler do
    let(:pool_id) { '12345' }
    let(:pool) { OpenStruct.new(:id => pool_id) }

    before do
      ::Actions::Candlepin::ReindexPoolSubscriptionHandler.any_instance.stubs(:attempt_find_pool).returns('id' => pool_id)
      ::Katello::Pool.stubs(:find_pool).returns(pool)
      ::Katello::Pool.stubs(:index_pools)
      ::Katello::Pool.stubs(:search).returns([pool])
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
        ::Katello::Pool.expects(:index_pools).with([pool])

        ::Actions::Candlepin::ReindexPoolSubscriptionHandler.new(Rails.logger).handle(mymessage)
      end
    end

    describe 'handles entitlement.deleted' do
      let(:mymessage) do
        message("entitlement.deleted", :referenceId => pool_id)
      end

      it 'reindex the pool' do
        ::Katello::Pool.expects(:index_pools).with([pool])

        ::Actions::Candlepin::ReindexPoolSubscriptionHandler.new(Rails.logger).handle(mymessage)
      end
    end

    describe 'handles pool.created' do
      let(:mymessage) do
        message "pool.created", :entityId => pool_id
      end

      it 'adds pool to index and reindex the pool' do
        ::Actions::Candlepin::ReindexPoolSubscriptionHandler.new(Rails.logger).handle(mymessage)
      end
    end

    describe 'handles pool.deleted' do
      let(:mymessage) do
        message "pool.deleted", :entityId  => pool_id
      end

      it 'pool removed from index' do
        ::Katello::Pool.expects(:remove_from_index).with(pool_id)
        ::Actions::Candlepin::ReindexPoolSubscriptionHandler.new(Rails.logger).handle(mymessage)
      end
    end
  end
end
