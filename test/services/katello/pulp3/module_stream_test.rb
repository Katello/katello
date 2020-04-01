require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class ModuleStreamTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @repo = katello_repositories(:fedora_17_x86_64_duplicate)
        end

        def pulp_module_data
          {
            "repository_memberships" => [@repo.pulp_id],
            "_storage_path" => "/var/lib/pulp/content/units/modulemd/04/f5586ee14de4e35c67ab08d26cb7a05e7fff0de07dceab66133a5820c382ce",
            "name" => "duck",
            "stream" => "0",
            "artifacts" => ["duck-0:0.7-1.noarch", "cat-0:0.8-1.noarch"],
            "checksum" => "7e57227ce357ab585349301507eee064b034c188088d7bab7a4025adcb6873b6",
            "_last_updated" => "2018-08-08T18:28:44Z",
            "_content_type_id" => "modulemd",
            "profiles" => {"default" => ["duck", "cat"]},
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

        def test_update_model
          model = Katello::ModuleStream.create(:pulp_id => 'foo')

          service = Katello::Pulp3::ModuleStream.new(model.pulp_id)
          service.backend_data = pulp_module_data
          service.update_model(model)

          assert_equal model.name, pulp_module_data['name']
          assert_equal 2, model.artifacts.count
          assert_equal 1, model.profiles.count
        end
      end
    end
  end
end
