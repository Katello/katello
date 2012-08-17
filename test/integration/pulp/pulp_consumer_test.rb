require 'test/integration/pulp/vcr_pulp_setup'
require 'test/integration/pulp/helpers/repository_helper'


module TestPulpConsumerBase
  include RepositoryHelper

  def setup
    @resource = Resources::Pulp::Consumer
    @consumer_id = "integration_test_consumer"
    VCR.insert_cassette('pulp_consumer')
  end

  def teardown
    if !@task.nil?
      Resources::Pulp::Task.cancel(@task["id"])
      while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
        @task = RepositoryHelper.task_resource.find([@task["id"]]).first
        sleep 0.5 # do not overload backend engines
      end
    end
    VCR.eject_cassette
  end

  def create_consumer(package_profile=false)
    @resource.create("", @consumer_id)

    if package_profile
      @resource.upload_package_profile(@consumer_id, [{"name" => "elephant", "version" => "0.2", "release" => "0.7", 
                                                      "epoch" => 0, "arch" => "noarch"}])
    end
  rescue Exception => e
  end

  def destroy_consumer
    @resource.destroy(@consumer_id)
  rescue Exception => e
  end

  def bind_repo
    @resource.bind(@consumer_id, RepositoryHelper.repo_id)
  end

end


class TestPulpConsumerCreate < MiniTest::Unit::TestCase
  include TestPulpConsumerBase

  def teardown
    destroy_consumer
    super
  end

  def test_create
    response = create_consumer
    assert response.kind_of? Hash
    assert response['id'] == @consumer_id
  end
end


class TestPulpConsumer < MiniTest::Unit::TestCase
  include TestPulpConsumerBase

  def setup
    super
    create_consumer
  end

  def teardown
    destroy_consumer
    super
  end

  def test_consumer_path
    path = @resource.consumer_path
    assert_match('/api/consumers/', path)
  end

  def test_consumer_path_with_id
    path = @resource.consumer_path(@consumer_id)
    assert_match("/api/consumers/#{@consumer_id}/", path)
  end

  def test_find
    response = @resource.find(@consumer_id)
    assert response.length > 0
    assert response['id'] == @consumer_id
  end

  def test_update
    response = @resource.update("", @consumer_id, "Test description")
    assert response == "true"
  end

  def test_upload_package_profile
    response = @resource.upload_package_profile(@consumer_id, [{"vendor" => "FedoraHosted", "name" => "elephant", 
                                                                "version" => "0.3", "release" => "0.8", 
                                                                "arch" => "noarch"}])
    assert response == "true"
  end

  def test_destroy
    response = destroy_consumer
    assert response == 200
  end
end


class TestPulpConsumerRequiresRepo < MiniTest::Unit::TestCase
  include TestPulpConsumerBase

  def setup
    super
    RepositoryHelper.create_and_sync_repo
    destroy_consumer
    create_consumer(true)
    bind_repo
  end

  def teardown
    RepositoryHelper.destroy_repo
    destroy_consumer
    super
  end

  def test_installed_packages
    response = @resource.installed_packages(@consumer_id)
    assert response.length > 0
    assert response.select { |pack| pack['name'] == 'elephant' }.length > 0
  end

  def test_errata
    response = @resource.errata(@consumer_id)
    assert response.select { |errata| errata['id'] == "RHEA-2010:0002" }.length > 0
  end

  def test_bind
    @resource.unbind(@consumer_id, RepositoryHelper.repo_id)
    response = @resource.bind(@consumer_id, RepositoryHelper.repo_id)
    response = JSON.parse(response)
    assert response['repo']['name'] = RepositoryHelper.repo_name
  end

  def test_unbind
    response = @resource.unbind(@consumer_id, RepositoryHelper.repo_id)
    assert response == "true"
  end

  def test_repoids
    response = @resource.repoids(@consumer_id)
    assert response.key?(RepositoryHelper.repo_id)
  end

  def test_errata_by_consumer
    response = @resource.errata_by_consumer([OpenStruct.new({ :pulp_id => RepositoryHelper.repo_id})])
    assert response.key?("RHEA-2010:0002")
  end

  def test_install_errata
    response = @resource.install_errata(@consumer_id, ['RHEA-2010:0002'])
    @task = response
    assert response["method_name"] == "_installerrata"
  end

  def test_install_packages
    response = @resource.install_packages(@consumer_id, ['cheetah'])
    @task = response
    assert response["method_name"] == "__installpackages"
  end

  def test_uninstall_packages
    response = @resource.uninstall_packages(@consumer_id, ['elephant'])
    @task = response
    assert response["method_name"] == "__uninstallpackages"
  end

  def test_update_packages
    response = @resource.update_packages(@consumer_id, ['elephant'])
    @task = response
    assert response["method_name"] == "__updatepackages"
  end

  def test_install_package_groups
    response = @resource.install_package_groups(@consumer_id, ['mammals'])
    @task = response
    assert response["method_name"] == "__installpackagegroups"
  end

  def test_uninstall_package_groups
    response = @resource.uninstall_package_groups(@consumer_id, ['mammals'])
    @task = response
    assert response["method_name"] == "__uninstallpackagegroups"
  end

end
