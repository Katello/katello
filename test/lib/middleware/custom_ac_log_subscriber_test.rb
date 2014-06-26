require 'katello_test_helper'

module Katello
class CustomACLogSubscriberTest < ActiveSupport::TestCase
  def setup
    @log_subscriber = Katello::Middleware::CustomAcLogSubscriber.new
    Katello.config.logging.stubs(:filter_parameters_by_path).returns([{"path"=> "foo_path", "names" => ['name', 'id']}])
  end

  def test_start_processing_when_config_is_not_set_
    Katello.config.logging.stubs(:filter_parameters_by_path).returns(nil)
    @event = OpenStruct.new({:payload => {:path => '/katello/foo_path', :params => {}}})
    @log_subscriber.start_processing(@event)
  end

  def test_start_processing_with_filtering
     @log_subscriber.expects(:log_payload).with do |payload, params|
       params['foo'] == 'bar' && params['name'].include?("FILTERED") && params['id'].include?("FILTERED")
     end
    @event = OpenStruct.new({:payload => {:path => '/katello/foo_path', :params => {'foo' => 'bar', 'name' => 'blah', 'id' => 'blah' }}})
    @log_subscriber.start_processing(@event)
  end

  def test_start_processing_without_filtering
    @log_subscriber.expects(:log_payload).never
    @event = OpenStruct.new({:payload => {:path => '/katello/api/users/1/show', :params => {}}})
    @log_subscriber.start_processing(@event)
  end
end
end
