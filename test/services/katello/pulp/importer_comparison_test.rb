require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Pulp
    class TestImporterClass
      attr_accessor :id
      attr_accessor :config
    end

    class ImporterComparisonTest < ActiveSupport::TestCase
      include ImporterComparison
      def setup
        yum_config = {
          'relative_url' => '/foo/bar',
          'checksum_type' => nil,
          'http' => true,
          'https' => true,
          'proxy_host' => 'http://someurl.org',
          'proxy_username' => 'admin',
          'proxy_password' => 'redhat',
          'proxy_port' => 8888
        }
        @generated_importer = TestImporterClass.new
        @generated_importer.id = 6
        @generated_importer.config = yum_config.clone
        @capsule_importer = {
          'config' => yum_config.clone,
          'importer_type_id' => 6
        }
      end

      def test_importer_matches_rejects_inqeual_ids
        @generated_importer.id = 12
        @capsule_importer['imported_type_id'] = 2
        refute importer_matches?(@generated_importer, @capsule_importer)
      end

      def test_importer_matches_ignores_proxy_values_if_host_is_blank
        @generated_importer.config['proxy_host'] = ""
        assert importer_matches?(@generated_importer, @capsule_importer)
      end

      def test_importer_matches_ignores_proxy_password_if_generated_is_blank
        @generated_importer.config['proxy_password'] = ""
        @capsule_importer['config']['proxy_password'] = "*****"
        assert importer_matches?(@generated_importer, @capsule_importer)
      end

      def test_importer_matches_accepts_equivalent_configs
        assert importer_matches?(@generated_importer, @capsule_importer)
      end
    end
  end
end
