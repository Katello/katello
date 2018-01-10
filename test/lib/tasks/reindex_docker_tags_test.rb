require 'katello_test_helper'
require 'rake'

module Katello
  class ReindexDockerTagsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/3.4/reindex_docker_tags'

      Rake::Task['katello:upgrades:3.4:reindex_docker_tags'].reenable
      Rake::Task.define_task(:environment)
    end

    def test_task
      Katello::DockerManifest.expects(:import_all).once.returns(true)
      Katello::DockerTag.expects(:import_all).once.returns(true)

      Rake.application.invoke_task('katello:upgrades:3.4:reindex_docker_tags')
    end
  end
end
