# encoding: utf-8

require 'katello_test_helper'

module Katello
  class ContainerExtensionsTest < ActiveSupport::TestCase
    def setup
      @container = FactoryGirl.create(:container)
      Setting['pulp_docker_registry_port'] = 6000
    end

    def test_container_repo_url
      counter = OpenStruct.new(:count => 1)
      hostname = "www.redhat-registry.com"
      capsule = mock
      capsule.expects(:url => "http://" + hostname + ":8000")
      @container.stubs(:capsule).returns(capsule)
      Repository.expects(:where).with(:container_repository_name => @container.repository_name).returns(counter)
      url = @container.repository_pull_url
      assert_equal "#{hostname}:6000/#{@container.repository_name}:#{@container.tag}", url
    end

    def test_container_repo_url_no_capsule
      counter = OpenStruct.new(:count => 1)
      hostname = "www.redhat-registry.com"
      default_capsule = mock
      CapsuleContent.expects(:default_capsule).returns(default_capsule)
      capsule = mock
      capsule.expects(:url => "http://" + hostname + ":8000")
      default_capsule.expects(:capsule).returns(capsule)
      @container.stubs(:capsule).returns
      Repository.expects(:where).with(:container_repository_name => @container.repository_name).returns(counter)
      url = @container.repository_pull_url
      assert_equal "#{hostname}:6000/#{@container.repository_name}:#{@container.tag}", url
    end
  end
end
