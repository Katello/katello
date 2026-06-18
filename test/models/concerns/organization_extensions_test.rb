# encoding: utf-8

require 'katello_test_helper'

module Katello
  class OrganizationExtensionsTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      set_default_location
      @org = get_organization(:empty_organization)
    end

    def test_audit_manifest_action
      current_time = Time.now
      travel_to current_time do
        @org.audit_manifest_action("manifest updated")
      end
      assert_equal @org.manifest_refreshed_at.to_i, current_time.to_i
    end

    def test_manifest_history
      @org.expects(:imports).returns([{'foo' => 'bar' }, {'foo' => 'bar'}])
      assert_equal 'bar', @org.manifest_history[0].foo
    end

    def test_nullify_acs_ssl_credentials_clears_acs_references_before_destroy
      cc_ids = @org.gpg_keys.pluck(:id)

      assert Katello::AlternateContentSource.where(ssl_ca_cert_id: cc_ids).exists?,
             "expected ACS fixtures to reference the org's content credentials"

      @org.nullify_acs_ssl_credentials

      assert_empty Katello::AlternateContentSource.where(ssl_ca_cert_id: cc_ids)
      assert_empty Katello::AlternateContentSource.where(ssl_client_cert_id: cc_ids)
      assert_empty Katello::AlternateContentSource.where(ssl_client_key_id: cc_ids)
    end

    def test_nullify_acs_ssl_credentials_is_noop_without_gpg_keys
      org_without_ccs = get_organization(:organization2)
      org_without_ccs.gpg_keys.delete_all

      assert_nothing_raised { org_without_ccs.nullify_acs_ssl_credentials }
    end
  end
end
