require 'katello_test_helper'

module Katello
  class PulpSyncStatusTest < ActiveSupport::TestCase
    def test_convert_history
      item = [{
        'started' => Time.now.to_s,
        'completed' => Time.now.to_s,
        'result' => 'failed'
      }]
      returned = PulpSyncStatus.convert_history(item).first
      assert_equal item.first['started'], returned['start_time']
      assert_equal item.first['completed'], returned['finish_time']
      assert_equal 'error', returned['state']
    end
  end
end
