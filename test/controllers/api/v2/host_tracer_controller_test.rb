# encoding: utf-8

require "katello_test_helper"

unless Katello.with_remote_execution?
  class JobInvocationComposer
  end
end

module Katello
  class Api::V2::HostTracerControllerTest < ActionController::TestCase
    def models
      @host1 = hosts(:one)
      @host2 = hosts(:two)
    end

    def setup
      setup_foreman_routes
      models
    end

    def test_index
      @host1.host_traces.create!(:id => 1, :host_id => 1, :helper => 'agile', :app_type => 'foo', :application => 'scrumm')

      results = JSON.parse(get(:index, params: { :host_id => @host1.id }).body)

      assert_response :success
      assert_includes results['results'].collect { |item| item['id'] }, @host1.host_traces.first.id
    end

    def test_resolve_group_by_helper
      trace_one = Katello::HostTracer.create(host_id: @host1.id, application: 'rsyslog', app_type: 'daemon', helper: 'systemctl restart rsyslog')
      trace_two = Katello::HostTracer.create(host_id: @host2.id, application: 'rsyslog', app_type: 'daemon', helper: 'systemctl restart rsyslog')
      helper = {:helper => trace_two.helper}

      job_invocation = {"description" => "Restart Services", "id" => 1, "job_category" => "Katello"}
      JobInvocationComposer.expects(:for_feature).with(:katello_service_restart, [@host1.id, @host2.id], helper).returns(mock(trigger: true, job_invocation: job_invocation))

      put :resolve, params: { use_route: 'traces/resolve', :trace_ids => [trace_one.id, trace_two.id]}

      assert_response :success

      response_body = JSON.parse(response.body)
      assert_equal response_body, [job_invocation]
    end

    def test_resolve_reboot_service
      trace = Katello::HostTracer.create(host_id: @host1.id, application: 'kernel', app_type: 'static', helper: 'reboot the system')
      helper = {:helper => 'reboot'}

      job_invocation = {"description" => "Restart Services", "id" => 1, "job_category" => "Katello"}
      JobInvocationComposer.expects(:for_feature).with(:katello_service_restart, [@host1.id], helper).returns(mock(trigger: true, job_invocation: job_invocation))

      put :resolve, params: { use_route: 'traces/resolve', :trace_ids => [trace.id]}

      assert_response :success

      response_body = JSON.parse(response.body)
      assert_equal response_body, [job_invocation]
    end

    def test_group_by_host_ids
      trace_one = Katello::HostTracer.create(host_id: @host1.id, application: 'rsyslog', app_type: 'daemon', helper: 'systemctl restart rsyslog')
      trace_two = Katello::HostTracer.create(host_id: @host2.id, application: 'tuned', app_type: 'daemon', helper: 'systemctl restart tuned')
      trace_three = Katello::HostTracer.create(host_id: @host2.id, application: 'firewalld', app_type: 'daemon', helper: 'systemctl restart firewalld')
      job_invocation = {"description" => "Restart Services", "id" => 1, "job_category" => "Katello"}
      helpers = [trace_two.helper, trace_three.helper].join(',')

      JobInvocationComposer.expects(:for_feature).with(:katello_service_restart, [@host1.id], {:helper => trace_one.helper}).returns(mock(trigger: true, job_invocation: job_invocation))
      JobInvocationComposer.expects(:for_feature).with(:katello_service_restart, [@host2.id], {:helper => helpers}).returns(mock(trigger: true, job_invocation: job_invocation))

      put :resolve, params: { use_route: 'traces/resolve', :trace_ids => [trace_one.id, trace_two.id, trace_three.id]}

      assert_response :success

      response_body = JSON.parse(response.body)
      assert_equal [job_invocation, job_invocation], response_body
    end
  end
end
