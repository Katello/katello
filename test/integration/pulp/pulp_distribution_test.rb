require 'test/integration/pulp/vcr_pulp_setup'


module TestPulpDistributionBase
  def setup
    @resource = Resources::Pulp::Distribution
    @repo_url = "http://lzap.fedorapeople.org/fakerepos/zoo5/"
    @repo_name = "integration_test_repo"
    @task = {}
    VCR.insert_cassette('pulp_distribution')
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
    while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
      @task = Resources::Pulp::Task.find([@task["id"]]).first
      sleep 0.5 # do not overload backend engines
    end
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


class TestPulpDistribution < MiniTest::Unit::TestCase
  include TestPulpDistributionBase

  def setup
    super
    create_repo
    sync_repo
  end

  def teardown
    destroy_repo(@repo_name, true)
    super
  end

  def test_dist_path
    path = @resource.dist_path
    assert_match("/api/distributions/", path)
  end

  def test_find
    repo = Resources::Pulp::Repository.find(@repo_name)
    response = @resource.find(repo['distributionid'].first)
    assert response.length > 0
  end

end
