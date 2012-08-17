module RepositoryHelper

  #@repo_url = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("pulp", "fixtures/repositories/zoo5")
  @repo_url = "http://lzap.fedorapeople.org/fakerepos/zoo5/"
  @repo_id = "integration_test_id"
  @repo_name = @repo_id
  @repo_resource = Resources::Pulp::Repository
  @task_resource = Resources::Pulp::Task

  def self.repo_name
    @repo_name
  end

  def self.repo_id
    @repo_id
  end

  def self.task_resource
    @task_resource
  end

  def self.create_and_sync_repo
    create_repo
    sync_repo
  end

  def self.create_repo
    VCR.use_cassette('pulp_repository') do
      destroy_repo
      @repo_resource.create(:id => @repo_id, :name=> @repo_name, :arch => 'noarch', :feed => @repo_url)
    end
  end

  def self.sync_repo
    VCR.use_cassette('pulp_repository') do
      @task = @repo_resource.sync(@repo_name)

      while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
        @task = @task_resource.find([@task["id"]]).first
        sleep 0.5 # do not overload backend engines
      end
    end
  end

  def self.destroy_repo(id=@repo_name, sync=true)
    VCR.use_cassette('pulp_repository') do
      if sync && @task
        @task_resource.cancel(@task["id"])
        while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
          @task = @task_resource.find([@task["id"]]).first
          sleep 0.5 # do not overload backend engines
        end
      end

      @repo_resource.destroy(id)
    end
  rescue Exception => e
  end

end
