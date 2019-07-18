require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Services
    class SrpmNonVcrTest < ActiveSupport::TestCase
      def test_update_model
        pulp_id = 'foo'
        model = Srpm.create!(:pulp_id => pulp_id)
        json = model.attributes.merge('summary' => 'an update', 'version' => '3', 'release' => '4')

        service = Katello::Pulp::Srpm.new(pulp_id)
        service.backend_data = json
        service.update_model(model)

        model = model.reload

        assert_equal model.summary, json['summary']
        refute model.release_sortable.blank?
        refute model.version_sortable.blank?
        refute model.nvra.blank?
      end

      def test_update_model_is_idempotent
        srpm = katello_srpms(:one)
        last_updated = srpm.updated_at
        json = srpm.attributes

        service = Katello::Pulp::Srpm.new(srpm.pulp_id)
        service.backend_data = json
        service.update_model(srpm)

        assert_equal srpm.reload.updated_at, last_updated
      end
    end
  end
end
