require 'katello_test_helper'
require 'rake'
require 'vcr'

module Katello
  class CheckCandlepinContentTest < ActiveSupport::TestCase
    include VCR::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/check_candlepin_content'
      Rake.application.rake_require 'katello/tasks/reimport' # needed for check_ping
      Rake::Task['katello:check_candlepin_content'].reenable
      Rake::Task['katello:check_ping'].reenable
      Rake::Task.define_task('dynflow:client')
      Rake::Task.define_task(:environment)
      Rake::Task.define_task(:check_ping)

      @library_repo = katello_repositories(:fedora_17_x86_64)
      ::Katello::Pulp3::RepositoryReference.new(repository_href: "test_repo_1/", root_repository_id: @library_repo.root_id, content_view_id: @library_repo.content_view.id).save
    end

    def test_candlepin_check_with_bad_ping
      Katello::Ping.expects(:ping).returns(:status => 'bad')
      assert_raises(RuntimeError) do
        Rake.application.invoke_task('katello:check_candlepin_content')
      end
    end

    def test_candlepin_content_check_with_missing_repos
      Katello::Ping.expects(:ping).returns(:status => 'ok')
      Katello::Util::CandlepinRepositoryChecker.expects(:repository_exist_in_backend?).at_most(14)
      Rake.application.invoke_task('katello:check_candlepin_content')
    end
  end
end
