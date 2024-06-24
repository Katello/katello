require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class ModuleStreamTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @repo = katello_repositories(:fedora_17_x86_64_duplicate)
          @rpm1 = Katello::Rpm.new(pulp_id: "pulp3/href1")
          @rpm2 = Katello::Rpm.new(pulp_id: "pulp3/href2")
          @rpm1.save!
          @rpm2.save!
        end

        def teardown
          @rpm1.destroy!
          @rpm2.destroy!
        end

        def pulp_module_data
          {
            "pulp_href": "/pulp/api/v3/content/rpm/modulemds/fc848d53-8af5-4175-bee6-7ceea8ea240d/",
            "pulp_created": "2022-01-10T13:24:31.630885Z",
            "md5": nil,
            "sha1": "779d68c3a5962ba9c11eb8bbb73e76366fde870e",
            "sha224": "d9ba416b13d204e36665d9b78aff8614188deeab66b5c3c70a6eaa6b",
            "sha256": "64d7a4276765b3db6d7342cc77f73de6ebad6caf6b29da7dcc01e3b305b3ceb8",
            "sha384": "04c7d1594b825575acd843338bca557630bc35cfbc4760fe6165b5845348b073e5a73b5fce60aff51798cfbef583861e",
            "sha512": "68fab7d85db3da6d2c1c9268da21f27ba8e2b1a549a6d5b8cced13506e8714528ed8d7216bdbfa426a85c9a4125b06a1c01c62fb86a04f75b93367e276869fc0",
            "artifact": "/pulp/api/v3/artifacts/0585f73a-dac2-4c5d-967e-3b21fa1bef08/",
            "name": "walrus",
            "stream": "5.21",
            "version": "20180704144203",
            "static_context": false,
            "profiles" => {"default" => ["duck", "cat"]},
            "context": "deadbeef",
            "arch": "x86_64",
            "artifacts": [
              "walrus-0:5.21-1.noarch",
              "foobar-8.noarch"
            ],
            "dependencies": [

            ],
            "packages": ["pulp3/href1", "pulp3/href2"],
          }.with_indifferent_access
        end

        def test_insert_child_associations
          model = Katello::ModuleStream.create(:pulp_id => pulp_module_data['pulp_href'])

          service = Katello::Pulp3::ModuleStream.new(model.pulp_id)
          service.class.insert_child_associations([pulp_module_data], {model.pulp_id => model.id})

          model.reload
          assert_equal 2, model.artifacts.count
          assert_equal 1, model.profiles.count
          assert_equal 2, model.rpms.count
        end
      end
    end
  end
end
