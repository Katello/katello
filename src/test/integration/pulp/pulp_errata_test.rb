require 'test/integration/pulp/vcr_pulp_setup'


module TestPulpErrataBase
  def setup
    @resource = Resources::Pulp::Errata
    @repo_url = "http://lzap.fedorapeople.org/fakerepos/zoo5/"
    @repo_name = "integration_test_repo"
    @task = {}
    VCR.insert_cassette('pulp_errata')
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


class TestPulpErrata < MiniTest::Unit::TestCase
  include TestPulpErrataBase

  def setup
    super
    create_repo
    sync_repo
  end

  def teardown
    destroy_repo(@repo_name, true)
    super
  end

  def test_errata_path
    path = @resource.errata_path
    assert_match("/api/errata/", path)
  end

  def test_find
    response = @resource.find("RHEA-2010:0002")
    assert response.length > 0
    assert response['id'] == 'RHEA-2010:0002'
  end

  def test_filter
    response = @resource.filter({ :type => "security" })
    assert response.length > 0
    assert response.select { |errata| errata['id'] == "RHEA-2010:0002" }.length > 0
  end


end
