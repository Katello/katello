require 'katello_test_helper'

module Katello
  class ActivationKeySubscriptionsPresenterTest < ActiveSupport::TestCase
    test 'key pools are filtered by Pool cp_id' do
      pool = mock('Pool')
      key_pools = [{'id' => 'foo', amount: 5}, {'id' => 'bar', amount: 10}]
      pool.expects(:cp_id).at_least_once.returns('foo')
      presenter = ActivationKeySubscriptionsPresenter.new(pool, key_pools)
      assert_equal(5, presenter.quantity_attached)
    end
  end
end
