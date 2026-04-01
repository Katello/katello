require 'katello_test_helper'

module Katello
  module Resources
    module Candlepin
      class CandlepinPingTest < ActiveSupport::TestCase
        def setup
          Rails.cache.delete(CandlepinPing::CACHE_KEY)
        end

        def teardown
          Rails.cache.delete(CandlepinPing::CACHE_KEY)
        end

        # ping — live poll by default (try_cache: false), backward compatible

        def test_ping_always_fetches_from_candlepin
          response = {'mode' => 'NORMAL', 'managerCapabilities' => []}.with_indifferent_access
          CandlepinPing.expects(:get).once.returns(stub(:body => response.to_json))

          result = CandlepinPing.ping

          assert_equal 'NORMAL', result['mode']
        end

        def test_ping_bypasses_existing_cache
          stale = {'mode' => 'SUSPEND', 'managerCapabilities' => []}.with_indifferent_access
          Rails.cache.write(CandlepinPing::CACHE_KEY, stale, expires_in: CandlepinPing::CACHE_TTL)

          fresh = {'mode' => 'NORMAL', 'managerCapabilities' => []}.with_indifferent_access
          CandlepinPing.expects(:get).returns(stub(:body => fresh.to_json))

          result = CandlepinPing.ping

          assert_equal 'NORMAL', result['mode']
        end

        def test_ping_writes_to_cache
          response = {'mode' => 'NORMAL', 'managerCapabilities' => []}.with_indifferent_access
          CandlepinPing.stubs(:get).returns(stub(:body => response.to_json))

          CandlepinPing.ping

          assert_not_nil Rails.cache.read(CandlepinPing::CACHE_KEY)
        end

        # ping(try_cache: true) — serves from cache when warm, falls back on cold miss

        def test_ping_try_cache_serves_from_warm_cache
          cached_response = {'mode' => 'NORMAL', 'managerCapabilities' => []}.with_indifferent_access
          Rails.cache.write(CandlepinPing::CACHE_KEY, cached_response, expires_in: CandlepinPing::CACHE_TTL)

          CandlepinPing.expects(:get).never

          result = CandlepinPing.ping(try_cache: true)

          assert_equal 'NORMAL', result['mode']
        end

        def test_ping_try_cache_fetches_from_candlepin_on_cold_miss
          response = {'mode' => 'NORMAL', 'managerCapabilities' => []}.with_indifferent_access
          CandlepinPing.expects(:get).once.returns(stub(:body => response.to_json))

          result = CandlepinPing.ping(try_cache: true)

          assert_equal 'NORMAL', result['mode']
        end

        def test_ping_try_cache_writes_to_cache_on_cold_miss
          response = {'mode' => 'NORMAL', 'managerCapabilities' => []}.with_indifferent_access
          CandlepinPing.stubs(:get).returns(stub(:body => response.to_json))

          CandlepinPing.ping(try_cache: true)

          assert_not_nil Rails.cache.read(CandlepinPing::CACHE_KEY)
        end

        # ok?

        def test_ok_returns_true_when_normal
          CandlepinPing.stubs(:ping).returns({'mode' => 'NORMAL'}.with_indifferent_access)
          assert CandlepinPing.ok?
        end

        def test_ok_returns_false_when_suspended
          CandlepinPing.stubs(:ping).returns({'mode' => 'SUSPEND'}.with_indifferent_access)
          refute CandlepinPing.ok?
        end

        def test_ok_uses_try_cache
          CandlepinPing.expects(:ping).with(try_cache: true).returns({'mode' => 'NORMAL'}.with_indifferent_access)
          CandlepinPing.ok?
        end

        # clear_cache

        def test_clear_cache_deletes_cache_key
          Rails.cache.write(CandlepinPing::CACHE_KEY, {'mode' => 'NORMAL'}.with_indifferent_access,
                            expires_in: CandlepinPing::CACHE_TTL)
          CandlepinPing.clear_cache
          assert_nil Rails.cache.read(CandlepinPing::CACHE_KEY)
        end
      end
    end
  end
end
