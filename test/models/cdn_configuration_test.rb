require 'katello_test_helper'

module Katello
  class CdnConfigurationTest < ActiveSupport::TestCase
    NON_REDHAT_FIELDS = [:username, :password, :upstream_organization_label, :ssl_ca_credential_id].freeze

    def test_redhat_configuration
      config = FactoryBot.build(:katello_cdn_configuration)

      NON_REDHAT_FIELDS.each do |field|
        assert_nil config.attributes[field.to_s]
      end

      assert config.redhat?
      assert config.valid?
    end

    def test_non_redhat_configuration
      NON_REDHAT_FIELDS.each do |field|
        config = FactoryBot.build(:katello_cdn_configuration)

        config.assign_attributes(field => 'Something')
        refute config.valid?
        refute config.redhat?
        assert_equal 1, config.errors.size

        assert_match(/when using a non-Red Hat/, config.errors.messages[:base].first)
      end
    end
  end
end
