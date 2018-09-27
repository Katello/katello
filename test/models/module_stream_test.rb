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

    def test_update_from_json
      @module_stream_empty.update_from_json(pulp_module_data)
      assert_equal @module_stream_empty.name, pulp_module_data['name']
      assert_equal @module_stream_empty.version, pulp_module_data['version'].to_s
      assert_equal @module_stream_empty.context, pulp_module_data['context']
      assert_equal @module_stream_empty.stream, pulp_module_data['stream']
      assert_equal @module_stream_empty.arch, pulp_module_data['arch']
      assert @module_stream_empty.artifacts.first.name, pulp_module_data['artifacts'].first
      assert @module_stream_empty.profiles.first.name, pulp_module_data['profiles'].keys.first
      assert @module_stream_empty.profiles.first.rpms.first.name, pulp_module_data['profiles'].values.first.first
    end

    def test_repositories_relation
      assert @module_stream_river.repositories.include?(@fedora_repo)
    end

    def test_profiles_relation
      assert @module_stream_river.profiles.include?(@module_profile_tributary)
    end

    def test_rpms_relation
      assert @module_stream_river.artifacts.include?(@module_stream_artifact_boat)
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
      module_streams = ModuleStream.search_for("uuid = \"#{@module_stream_river.uuid}\"")
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
        [{:name => "boo", :version => "11111", :context => "cccc", :arch => "noarch"}, "boo"]
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

    def pulp_module_data
      @pulp_module_data ||= {
        "repository_memberships" => [@fedora_repo.pulp_id],
        "_storage_path" => "/var/lib/pulp/content/units/modulemd/04/f5586ee14de4e35c67ab08d26cb7a05e7fff0de07dceab66133a5820c382ce",
        "name" => "duck",
        "stream" => "0",
        "artifacts" => ["duck-0:0.7-1.noarch"],
        "checksum" => "7e57227ce357ab585349301507eee064b034c188088d7bab7a4025adcb6873b6",
        "_last_updated" => "2018-08-08T18:28:44Z",
        "_content_type_id" => "modulemd",
        "profiles" => {"default" => ["duck"]},
        "summary" => "Duck 0.7 module",
        "_href" => "/pulp/api/v2/content/units/modulemd/2c5ebdc1-1504-4089-a318-c83ace3acdde/",
        "downloaded" => true,
        "version" => 20_180_730_233_102,
        "pulp_user_metadata" => {},
        "context" => "deadbeef",
        "_id" => "2c5ebdc1-1504-4089-a318-c83ace3acdde",
        "arch" => "noarch",
        "children" => {},
        "description" => "A module for the duck 0.7 package"
      }
    end
  end
end
