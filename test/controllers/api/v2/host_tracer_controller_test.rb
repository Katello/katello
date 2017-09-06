# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostTracerControllerTest < ActionController::TestCase
    def models
      @host = hosts(:one)
      @host.host_traces.create!(:app_type => 'foo', :application => 'scrumm')
    end

    def setup
      setup_foreman_routes
      models
    end

    def test_index
      results = JSON.parse(get(:index, :host_id => @host.id).body)

      assert_response :success
      assert_includes results['results'].collect { |item| item['id'] }, @host.host_traces.first.id
    end
  end
end
