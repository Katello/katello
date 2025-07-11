require 'katello_test_helper'
require 'rake'
require 'support/pulp3_support'

module Katello
  module Pulp3
    class RepositoryTaskTest < ActiveSupport::TestCase
      include Katello::Pulp3Support

      def setup
        Rake.application.rake_require 'katello/tasks/repository'
        Rake.application.rake_require 'katello/tasks/reimport'

        Rake::Task.define_task('dynflow:client')

        Rake::Task['katello:correct_repositories'].reenable
        Rake::Task['dynflow:client'].reenable
        Rake::Task['katello:check_ping'].reenable

        Rake::Task.define_task(:environment)

        @primary = SmartProxy.pulp_primary
        @library_repo = katello_repositories(:fedora_17_x86_64_duplicate)
        @library_repo.root.update(:url => 'https://fixtures.pulpproject.org/rpm-no-comps/')
        @backend_service = ::Katello::Pulp3::Repository::Yum.new(@library_repo, @primary)

        ENV['COMMIT'] = nil
        ENV['CONTENT_VIEW'] = nil
        ENV['LIFECYCLE_ENVIRONMENT'] = nil
        User.stubs(:current).returns(users(:admin))
        create_repo(@library_repo, @primary)
      end

      def test_correct_repositories_fixes_deleted_library_repo
        ENV['COMMIT'] = 'true'

        @backend_service.delete_remote
        @backend_service.delete_repository

        Katello::Repository.where("id not in (#{@library_repo.id})").each do |repo|
          repo.library_instances_inverse.destroy_all
        end

        # For some reason, the first `destroy_all` leaves records behind.
        Katello::Repository.where("id not in (#{@library_repo.id})").destroy_all
        Katello::Repository.where("id not in (#{@library_repo.id})").destroy_all

        Rake.application.invoke_task('katello:correct_repositories')
        @backend_service.read
      end
    end
  end
end
