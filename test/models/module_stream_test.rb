require 'katello_test_helper'

module Katello
  class ModuleStreamTest < ActiveSupport::TestCase
    def setup
      @fedora_repo = katello_repositories(:fedora_17_x86_64)
      @fedora_repo_in_env = katello_repositories(:fedora_17_x86_64_dev)
      @module_stream_river = katello_module_streams(:river)
      @module_stream_empty = katello_module_streams(:empty)
      @module_profile_tributary = katello_module_profiles(:tributary)
      @module_stream_artifact_boat = katello_module_stream_artifacts(:boat)
    end

    def test_clean_filter_rules
      ::Katello::RepositoryModuleStream.create!(module_stream_id: @module_stream_empty.id, repository_id: @fedora_repo.id)
      filter = FactoryBot.build(:katello_content_view_module_stream_filter, :inclusion => true)
      river_rule = FactoryBot.create(:katello_content_view_module_stream_filter_rule,
                                   :filter => filter,
                                   :module_stream_id => @module_stream_river.id)
      empty_rule = FactoryBot.create(:katello_content_view_module_stream_filter_rule,
                                   :filter => filter,
                                   :module_stream_id => @module_stream_empty.id)
      content_type = Katello::RepositoryTypeManager.find_content_type('modulemd')
      indexer = Katello::ContentUnitIndexer.new(content_type: content_type, repository: @fedora_repo)
      repo_associations = ::Katello::RepositoryModuleStream.where(module_stream_id: @module_stream_empty.id, repository_id: @fedora_repo.id)
      filter.content_view.update(organization_id: @fedora_repo.organization.id)
      filter.content_view.repositories << @fedora_repo
      indexer.clean_filter_rules(repo_associations)

      river_rule.reload
      assert_raises ActiveRecord::RecordNotFound do
        empty_rule.reload
      end
    end

    def test_repositories_relation
      assert_includes @module_stream_river.repositories, @fedora_repo
    end

    def test_profiles_relation
      assert_includes @module_stream_river.profiles, @module_profile_tributary
    end

    def test_rpms_relation
      assert_includes @module_stream_river.artifacts, @module_stream_artifact_boat
    end

    def test_search_name
      module_streams = ModuleStream.search_for("name = \"#{@module_stream_river.name}\"")
      assert_includes module_streams, @module_stream_river
    end

    def test_search_version
      module_streams = ModuleStream.search_for("version = \"#{@module_stream_river.version}\"")
      assert_includes module_streams, @module_stream_river
    end

    def test_search_uuid
      module_streams = ModuleStream.search_for("uuid = \"#{@module_stream_river.pulp_id}\"")
      assert_includes module_streams, @module_stream_river
    end

    def test_search_stream
      module_streams = ModuleStream.search_for("stream = \"#{@module_stream_river.stream}\"")
      assert_includes module_streams, @module_stream_river
    end

    def test_search_context
      module_streams = ModuleStream.search_for("context = \"#{@module_stream_river.context}\"")
      assert_includes module_streams, @module_stream_river
    end

    def test_search_arch
      module_streams = ModuleStream.search_for("arch = \"#{@module_stream_river.arch}\"")
      assert_includes module_streams, @module_stream_river
    end

    def test_search_repository_name
      module_streams = ModuleStream.search_for("repository = \"#{@fedora_repo.name}\"")
      assert_includes module_streams, @module_stream_river
    end

    def test_library_repositories
      repos = @module_stream_river.library_repositories
      assert_includes repos, @fedora_repo
      refute_includes repos, @fedora_repo_in_env
    end

    def test_available_hosts
      content_view = katello_content_views(:library_dev_view)
      environment = katello_environments(:library)
      host = FactoryBot.create(:host, :with_content, :content_view => content_view,
                                     :lifecycle_environment => environment)
      content_facet = host.content_facet
      content_facet.bound_repositories = [Katello::Repository.find(@fedora_repo.id)]
      content_facet.save!

      host_without_modules = hosts(:without_errata)
      assert_empty ModuleStream.available_for_hosts([host_without_modules.id])
      assert_empty ModuleStream.search_for("host=#{host_without_modules.name}")

      assert_includes ModuleStream.available_for_hosts([host.id]), @module_stream_river
      assert_includes ModuleStream.search_for("host=#{host.name}"), @module_stream_river
    end

    def test_module_spec
      inputs = [
        [{:name => "boo"}, "boo"],
        [{:name => "boo", :stream => "100"}, "boo:100"],
        [{:name => "boo", :stream => "100", :version => "11111"}, "boo:100:11111"],
        [{:name => "boo", :stream => "100", :version => "11111", :context => "cccc"}, "boo:100:11111:cccc"],
        [{:name => "boo", :stream => "100", :version => "11111", :context => "cccc", :arch => "noarch"}, "boo:100:11111:cccc:noarch"],
        [{:name => "boo", :stream => "100", :version => "11111", :arch => "noarch"}, "boo:100:11111"],
        [{:name => "boo", :stream => "100", :context => "cccc", :arch => "noarch"}, "boo:100"],
        [{:name => "boo", :version => "11111", :context => "cccc", :arch => "noarch"}, "boo"],
      ]
      inputs.each do |params, expectation|
        assert_equal expectation, ModuleStream.new(params).module_spec
        assert_equal expectation, ModuleStream.new(ModuleStream.parse_module_spec(expectation)).module_spec
      end
    end

    def test_module_spec_search
      assert_includes ModuleStream.search_for("module_spec=#{@module_stream_river.module_spec}"), @module_stream_river
      assert_includes ModuleStream.search_for("module_spec~#{@module_stream_river.name}"), @module_stream_river
      assert_includes ModuleStream.search_for("module_spec~#{@module_stream_river.name}:#{@module_stream_river.stream}"), @module_stream_river
    end
  end
end
