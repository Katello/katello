require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class RpmTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:fedora_17_x86_64_duplicate)
          @repo.root.update(:url => 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')
          ensure_creatable(@repo, @master)
          create_repo(@repo, @master)

          @repo.reload
        end

        def test_index_model
          Katello::Rpm.destroy_all
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
          @repo.reload
          @repo.index_content
          post_unit_count = Katello::Rpm.all.count
          post_unit_repository_count = Katello::RepositoryRpm.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 32
          assert_equal post_unit_repository_count, 32

          assert_equal 'bear-4.1-1.noarch', @repo.rpms.where(:name => 'bear').first.nvra
        end

        def test_index_on_sync
          Katello::Rpm.destroy_all
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload
          post_unit_count = Katello::Rpm.all.count
          post_unit_repository_count = Katello::RepositoryRpm.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 32
          assert_equal post_unit_repository_count, 32
        end

        def test_update_model
          pulp_id = 'foo'
          model = Rpm.create!(:pulp_id => pulp_id)
          json = model.attributes.merge('pulp_href' => 'my_href', 'summary' => 'an update', 'version' => '3', 'release' => '4', 'is_modular' => 'false')

          service = Katello::Pulp3::Rpm.new(pulp_id)
          service.backend_data = json
          service.update_model(model)

          model = model.reload

          assert_equal model.summary, json['summary']
          refute model.release_sortable.blank?
          refute model.version_sortable.blank?
          refute model.nvra.blank?
        end
      end
    end
  end
end
