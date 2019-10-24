require 'katello_test_helper'

module Katello
  class CandlepinListeningServiceTest < ActiveSupport::TestCase
    def setup
      @receiver = mock
      @session = mock(create_receiver: @receiver)
      @connection = mock(open?: false, open: true, create_session: @session)
      Katello::CandlepinListeningService.any_instance.stubs(:create_connection).returns(@connection)
      Katello::CandlepinListeningService.initialize_service(Rails.logger, 'some_url', 'some_address')
      @instance = Katello::CandlepinListeningService.instance
      @instance.start
    end

    def teardown
      @instance.stubs(:close).returns(true)
      Katello::CandlepinListeningService.close
    end

    def test_fetch_message
      @receiver.stubs(:fetch).returns(:some_message)
      @session.stubs(:acknowledge).returns(true)

      message = @instance.fetch_message

      assert_nil message[:error]
      assert_equal :some_message, message[:result]
    end

    def test_close
      @connection.stubs(:close).returns(true)

      @instance.close
    end
  end
end
