require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Service
    class OstreeBranchTest < ActiveSupport::TestCase
      BRANCHES = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "ostree_branch.yml")

      def setup
        @branches = YAML.load_file(BRANCHES).values.map(&:deep_symbolize_keys)
        @model = Katello::OstreeBranch.create!(:pulp_id => 'foo')
      end

      def test_update_model
        service = ::Katello::Pulp::OstreeBranch.new(@model.pulp_id)
        service.backend_data = @branches[0]
        service.update_model(@model)

        assert_equal @branches[0][:commit], @model.commit
        assert_equal @branches[0][:branch], @model.name
        refute_nil @model.version_date
      end

      def test_update_model_nil_created
        @branches[0][:_created] = nil
        service = ::Katello::Pulp::OstreeBranch.new(@model.pulp_id)
        service.backend_data = @branches[0]
        service.update_model(@model)

        assert_equal @branches[0][:commit], @model.commit
        assert_equal @branches[0][:branch], @model.name
        assert_nil @model.version_date
      end
    end
  end
end
