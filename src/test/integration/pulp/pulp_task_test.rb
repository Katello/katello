require 'test/integration/pulp/vcr_pulp_setup'


module TestPulpTaskBase
  def setup
    @resource = Resources::Pulp::Task
    @repo_url = "http://lzap.fedorapeople.org/fakerepos/zoo5/"
    @repo_name = "integration_test_repo"
    @task = {}
    VCR.insert_cassette('pulp_task')
  end

  def teardown
    VCR.eject_cassette
  end

  def create_repo
    Resources::Pulp::Repository.create(:id => @repo_name, :name=> @repo_name, :arch => 'noarch', :feed => @repo_url)
  rescue Exception => e
  end

  def sync_repo
    @task = Resources::Pulp::Repository.sync(@repo_name)
  end

  def destroy_repo(id=@repo_name, sync=false)
    if sync
      Resources::Pulp::Task.cancel(@task["id"])
      while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
        @task = Resources::Pulp::Task.find([@task["id"]]).first
        sleep 0.5 # do not overload backend engines
      end
    end

    @resource.destroy(id)

  rescue Exception => e
  end

end


class TestPulpTask < MiniTest::Unit::TestCase
  include TestPulpTaskBase

  def setup
    super
    create_repo
    sync_repo
  end

  def teardown
    destroy_repo(@repo_name, true)
    super
  end

  def test_path
    path = @resource.path
    assert_match("/api/tasks/", path)
  end

  def test_path_with_role_name
    path = @resource.path(@task['id'])
    assert_match("/api/tasks/" + @task['id'], path)
  end

  def test_find
    response = @resource.find([@task['id']])
    assert response.length > 0
    assert response.first['id'] == @task['id']
  end

  def test_cancel
    response = @resource.cancel(@task['id'])
    assert response.length > 0
  end

  def test_destroy
    response = @resource.destroy(@task['id'])
    assert response == '404'
  end

end
