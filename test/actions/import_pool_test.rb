require 'katello_test_helper'

module Katello
  describe ::Actions::Candlepin::ImportPoolHandler do
    let(:pool_id) { 'abc123' }
    let(:pool) { OpenStruct.new(:id => pool_id) }

    before do
      ::Actions::Candlepin::ImportPoolHandler.any_instance.stubs(:attempt_find_pool).returns('id' => pool_id)
      ::Katello::Pool.expects(:find_by).with(has_key(:cp_id)).returns(pool)
      ::Katello::Pool.stubs(:search).returns([pool])
      ::Katello::Pool.any_instance.stubs(:import_data).returns(true)
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
        message "pool.deleted", :entityId  => pool_id
      end

      it 'pool removed from index' do
        ::Actions::Candlepin::ImportPoolHandler.new(Rails.logger).handle(mymessage)
      end
    end
  end
end
