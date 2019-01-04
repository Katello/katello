require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Services
    class YumMetadataFileTest < ActiveSupport::TestCase
      def test_update_from_json
        pulp_id = 'foo'
        name = "foo.gz"
        model = YumMetadataFile.create!(:pulp_id => pulp_id)
        service = Katello::Pulp::YumMetadataFile.new(pulp_id)
        json = model.attributes.merge('checksum' => 'xxxxxx',
                                      '_storage_path' => "/var/lib/pulp/foo/#{name}").as_json
        service.backend_data = json
        service.update_model(model)
        model = model.reload
        refute model.checksum.blank?
        assert_equal name, model.name
      end
    end
  end
end
