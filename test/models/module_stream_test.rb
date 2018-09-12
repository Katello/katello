require 'katello_test_helper'

module Katello
  class ModuleStreamTest < ActiveSupport::TestCase
    def setup
      @fedora_repo = katello_repositories(:fedora_17_x86_64)
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
