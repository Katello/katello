require 'katello_test_helper'

module Katello
  class AlternateContentSourceCreateTest < ActiveSupport::TestCase
    let(:proxy) { FactoryBot.create(:http_proxy) }

    def setup
      @acs = katello_alternate_content_sources(:yum_alternate_content_source)
      Setting['content_default_http_proxy'] = proxy.name
    end

    def test_create
      assert @acs.save
      refute_empty AlternateContentSource.where(id: @acs.id)
    end

    def test_subpaths
      @acs.subpaths = ['test/', 'some_files/'].sort
      assert @acs.save
      assert @acs.subpaths.sort == ['test/', 'some_files/'].sort
    end

    def test_smart_proxies
      assert @acs.save
      SmartProxyAlternateContentSource.create(alternate_content_source_id: @acs.id, smart_proxy_id: ::SmartProxy.pulp_primary.id, remote_href: 'remote_href', alternate_content_source_href: 'acs_href')
      @acs.reload
      assert @acs.smart_proxies == [::SmartProxy.pulp_primary]
    end

    def test_http_proxy
      @acs.http_proxy = proxy
      assert @acs.save
      assert @acs.http_proxy = proxy
    end

    def test_custom_missing_base_url
      @acs.base_url = nil
      assert_raises(ActiveRecord::RecordInvalid, "Base url can\'t be blank") do
        @acs.save!
      end
    end

    def test_custom_missing_verify_ssl
      @acs.verify_ssl = nil
      assert_raises(ActiveRecord::RecordInvalid, "Verify ssl can\'t be blank") do
        @acs.save!
      end
    end

    def test_wrong_acs_type
      @acs.alternate_content_source_type = 'definitely not an ACS type'
      assert_raises(ActiveRecord::RecordInvalid, "Alternate content source type is not a valid type. Must be one of the following: #{AlternateContentSource::ACS_TYPES.join(',')}") do
        @acs.save!
      end
    end

    def test_wrong_content_type
      @acs.content_type = 'emu'
      assert_raises(ActiveRecord::RecordInvalid, "Content type is not allowed for ACS. Must be one of the following: #{AlternateContentSource::CONTENT_TYPES.join(',')}") do
        @acs.save!
      end
    end

    def test_custom?
      @acs.save!
      assert @acs.custom?
    end

    def test_with_type
      @acs.save!
      assert_equal [@acs], AlternateContentSource.with_type('yum')
    end
  end

  class AlternateContentSourceSearchTest < ActiveSupport::TestCase
    def setup
      @acs = katello_alternate_content_sources(:yum_alternate_content_source)
      @acs.subpaths = ['rpms/', 'packages/']
      SmartProxyAlternateContentSource.create(alternate_content_source_id: @acs.id, smart_proxy_id: ::SmartProxy.pulp_primary.id, remote_href: 'remote_href', alternate_content_source_href: 'acs_href')
      @acs.save
      @acs.reload
    end

    def test_search_name
      acss = AlternateContentSource.search_for("name = \"#{@acs.name}\"")
      assert_equal acss, [@acs]
    end

    def test_search_label
      acss = AlternateContentSource.search_for("label = \"#{@acs.label}\"")
      assert_equal acss, [@acs]
    end

    def test_search_base_url
      acss = AlternateContentSource.search_for("base_url = \"#{@acs.base_url}\"")
      assert_equal acss, [@acs]
    end

    def test_search_subpath
      acss = AlternateContentSource.search_for("subpath = \"rpms\/\"")
      assert_equal acss, [@acs]
      acss = AlternateContentSource.search_for("subpath = \"packages\/\"")
      assert_equal acss, [@acs]
    end

    def test_search_content_type
      acss = AlternateContentSource.search_for("content_type = \"#{@acs.content_type}\"")
      assert_equal acss, [@acs]
    end

    def test_search_acs_type
      acss = AlternateContentSource.search_for("alternate_content_source_type = \"#{@acs.alternate_content_source_type}\"")
      assert_equal acss, [@acs]
    end

    def test_search_upstream_username
      acss = AlternateContentSource.search_for("upstream_username = \"#{@acs.upstream_username}\"")
      assert_equal acss, [@acs]
    end

    def test_search_smart_proxy_id
      acss = AlternateContentSource.search_for("smart_proxy_id = \"#{@acs.smart_proxy_ids.first}\"")
      assert_equal acss, [@acs]
    end
  end
end