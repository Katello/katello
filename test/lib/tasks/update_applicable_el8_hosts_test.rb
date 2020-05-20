require 'katello_test_helper'
require 'rake'

module Katello
  class UpdateApplicableEl8HostsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/3.16/update_applicable_el8_hosts'
      Rake::Task['katello:upgrades:3.16:update_applicable_el8_hosts'].reenable
      Rake::Task.define_task(:environment)
      @host = katello_content_facets(:content_facet_two).host
    end

    def bind_repos(repo_name = :fedora_17_x86_64_dev)
      repo = katello_repositories(repo_name)
      @host.content_facet.bound_repositories << repo
      @host.content_facet.save!
    end

    def add_available_module_streams(status = 'enabled')
      available_module_stream = katello_available_module_streams(:available_module_stream_one)
      HostAvailableModuleStream.create!(available_module_stream: available_module_stream, host: @host, status: status)
    end

    def test_applicable_hosts_not_found_non_library
      bind_repos(:fedora_17_x86_64) # note this is a library repo, so should not get picked
      add_available_module_streams
      ::Actions::Katello::Host::UploadProfiles.expects(:upload_modules_to_pulp).never
      Rake.application.invoke_task('katello:upgrades:3.16:update_applicable_el8_hosts')
    end

    def test_applicable_hosts_not_found_no_stream
      # Host with no available module streams
      bind_repos
      ::Actions::Katello::Host::UploadProfiles.expects(:upload_modules_to_pulp).never
      Rake.application.invoke_task('katello:upgrades:3.16:update_applicable_el8_hosts')
    end

    def test_applicable_hosts_not_found_no_enabled_stream
      # Host with no available module streams
      bind_repos
      add_available_module_streams('unknown')
      ::Actions::Katello::Host::UploadProfiles.expects(:upload_modules_to_pulp).never
      Rake.application.invoke_task('katello:upgrades:3.16:update_applicable_el8_hosts')
    end

    def test_applicable_hosts_found
      bind_repos
      add_available_module_streams
      ::Actions::Katello::Host::UploadProfiles.expects(:upload_modules_to_pulp).once
      Rake.application.invoke_task('katello:upgrades:3.16:update_applicable_el8_hosts')
    end
  end
end
