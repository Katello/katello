require 'katello_test_helper'
module Katello
  class AlternateContentSourceCreateTest < ActiveSupport::TestCase
    let(:proxy) { FactoryBot.create(:http_proxy) }

    def setup
      @yum_acs = katello_alternate_content_sources(:yum_alternate_content_source)
      @file_acs = katello_alternate_content_sources(:file_alternate_content_source)
      @simplified_acs = katello_alternate_content_sources(:yum_simplified_alternate_content_source)
      @simplified_acs.verify_ssl = nil
      Setting['content_default_http_proxy'] = proxy.name
    end

    def test_create
      assert @yum_acs.save
      refute_empty AlternateContentSource.where(id: @yum_acs.id)
    end

    def test_duplicate_name
      assert @yum_acs.save
      yum_acs_dup_name = @yum_acs.dup
      assert_not_valid yum_acs_dup_name
      assert_equal yum_acs_dup_name.errors.full_messages, [
        "Label has already been taken",
        "Name has already been taken"
      ]
    end

    def test_products
      @simplified_acs.products << ::Katello::Product.find_by(name: 'Fedora')
      @simplified_acs.products << ::Katello::Product.find_by(name: 'Red Hat Linux')
      assert @simplified_acs.save
      assert_equal @simplified_acs.products.pluck(:name).sort, ['Fedora', 'Red Hat Linux'].sort
    end

    # A 'proper' repository has a URL and the same content type as the ACS.
    def test_cannot_add_product_if_repo_has_no_url
      repo_no_url = FactoryBot.create(:katello_repository, :with_product)
      repo_no_url.root.update!(url: nil)

      error = assert_raises ::ActiveRecord::RecordInvalid do
        @simplified_acs.products << repo_no_url.product
      end

      assert_equal "Validation failed: Product The product #{repo_no_url.product.name} has no yum repositories with upstream URLs to add to the alternate content source.", error.message
    end

    def test_cannot_add_product_with_no_repositories
      org = FactoryBot.create(:organization)
      provider = FactoryBot.create(:katello_provider, organization: org)
      empty_product = FactoryBot.create(:katello_product, organization: org, provider: provider, cp_id: '12345')
      error = assert_raises ::ActiveRecord::RecordInvalid do
        @simplified_acs.products << empty_product
      end

      assert_equal "Validation failed: Product The product #{empty_product.name} has no yum repositories with upstream URLs to add to the alternate content source.", error.message
    end

    def test_subpaths
      @yum_acs.subpaths = ['test/', 'some_files/'].sort
      assert @yum_acs.save
      assert_equal @yum_acs.subpaths.sort, ['test/', 'some_files/'].sort
    end

    def test_smart_proxies
      assert @yum_acs.save
      SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: ::SmartProxy.pulp_primary.id, remote_href: 'remote_href', alternate_content_source_href: 'acs_href')
      @yum_acs.reload
      assert_equal @yum_acs.smart_proxies, [::SmartProxy.pulp_primary]
    end

    def test_http_proxy
      @yum_acs.use_http_proxies = true
      assert @yum_acs.save
      assert @yum_acs.use_http_proxies
    end

    def test_custom_missing_base_url
      @yum_acs.base_url = nil
      assert_raises(ActiveRecord::RecordInvalid, "Base url can\'t be blank") do
        @yum_acs.save!
      end
    end

    def test_custom_missing_verify_ssl
      @yum_acs.verify_ssl = nil
      assert_raises(ActiveRecord::RecordInvalid, "Verify ssl can\'t be blank") do
        @yum_acs.save!
      end
    end

    def test_wrong_acs_type
      @yum_acs.alternate_content_source_type = 'definitely not an ACS type'
      assert_raises(ActiveRecord::RecordInvalid, "Alternate content source type is not a valid type. Must be one of the following: #{AlternateContentSource::ACS_TYPES.join(',')}") do
        @yum_acs.save!
      end
    end

    def test_wrong_content_type
      @yum_acs.content_type = 'emu'
      assert_raises(ActiveRecord::RecordInvalid, "Content type is not allowed for ACS. Must be one of the following: #{AlternateContentSource::CONTENT_TYPES.join(',')}") do
        @yum_acs.save!
      end
    end

    def test_custom?
      @yum_acs.save!
      assert @yum_acs.custom?
    end

    def test_with_type
      @yum_acs.save!
      @simplified_acs.save!
      assert_equal [@yum_acs, @simplified_acs].sort, AlternateContentSource.with_type('yum').sort
    end
  end

  class AlternateContentSourceSearchTest < ActiveSupport::TestCase
    def setup
      @yum_acs = katello_alternate_content_sources(:yum_alternate_content_source)
      @yum_acs.subpaths = ['rpms/', 'packages/']
      SmartProxyAlternateContentSource.create(alternate_content_source_id: @yum_acs.id, smart_proxy_id: ::SmartProxy.pulp_primary.id, remote_href: 'remote_href', alternate_content_source_href: 'acs_href')
      @yum_acs.save
      @yum_acs.reload

      @file_acs = katello_alternate_content_sources(:file_alternate_content_source)
      @file_acs.subpaths = ['files/', 'selif/']
      SmartProxyAlternateContentSource.create(alternate_content_source_id: @file_acs.id, smart_proxy_id: ::SmartProxy.pulp_primary.id, remote_href: 'remote_href2', alternate_content_source_href: 'acs_href2')
      @file_acs.save
      @file_acs.reload

      @simplified_acs = katello_alternate_content_sources(:yum_simplified_alternate_content_source)
      @repo1 = ::Katello::Repository.find_by(relative_path: 'ACME_Corporation/library/fedora_17_label_no_arch')
      @repo2 = ::Katello::Repository.find_by(relative_path: 'ACME_Corporation/library/fedora_17_label')
      @simplified_acs.products << @repo1.product
      SmartProxyAlternateContentSource.create(alternate_content_source_id: @simplified_acs.id, smart_proxy_id: ::SmartProxy.pulp_primary.id, remote_href: 'remote_href2', alternate_content_source_href: 'acs_href2', repository_id: @repo1.id)
      SmartProxyAlternateContentSource.create(alternate_content_source_id: @simplified_acs.id, smart_proxy_id: ::SmartProxy.pulp_primary.id, remote_href: 'remote_href2', alternate_content_source_href: 'acs_href2', repository_id: @repo2.id)
      @simplified_acs.save
      @simplified_acs.reload
    end

    def test_search_name
      acss = AlternateContentSource.search_for("name = \"#{@yum_acs.name}\"")
      assert_equal acss, [@yum_acs]
    end

    def test_search_label
      acss = AlternateContentSource.search_for("label = \"#{@yum_acs.label}\"")
      assert_equal acss, [@yum_acs]
    end

    def test_search_base_url
      acss = AlternateContentSource.search_for("base_url = \"#{@yum_acs.base_url}\"")
      assert_equal acss.sort, [@file_acs, @yum_acs].sort
    end

    def test_search_subpath
      acss = AlternateContentSource.search_for("subpath = \"rpms\/\"")
      assert_equal acss, [@yum_acs]
      acss = AlternateContentSource.search_for("subpath = \"packages\/\"")
      assert_equal acss, [@yum_acs]
    end

    def test_search_content_type
      acss = AlternateContentSource.search_for("content_type = \"#{@yum_acs.content_type}\"")
      assert_equal acss.sort, [@yum_acs, @simplified_acs].sort
    end

    def test_search_acs_type
      acss = AlternateContentSource.search_for("alternate_content_source_type = \"#{@yum_acs.alternate_content_source_type}\"")
      assert_equal acss.sort, [@file_acs, @yum_acs].sort
    end

    def test_search_upstream_username
      acss = AlternateContentSource.search_for("upstream_username = \"#{@yum_acs.upstream_username}\"")
      assert_equal acss.sort, [@file_acs, @yum_acs].sort
    end

    def test_search_smart_proxy_id
      # For some reason, searching by smart_proxy_id first causes a Postgres error only in the tests.
      # Searching by smart_proxy_name right before fixes the issue. It may have to do with caching.
      AlternateContentSource.search_for("smart_proxy_name = \"#{@yum_acs.smart_proxy_names.first}\"")
      acss = AlternateContentSource.search_for("smart_proxy_id = \"#{@yum_acs.smart_proxy_ids.first}\"")
      assert_equal acss.sort, [@file_acs, @yum_acs, @simplified_acs].sort
    end

    def test_search_smart_proxy_name
      acss = AlternateContentSource.search_for("smart_proxy_name = \"#{@yum_acs.smart_proxy_names.first}\"")
      assert_equal acss.sort, [@file_acs, @yum_acs, @simplified_acs].sort
    end

    def test_search_product_id
      acss = AlternateContentSource.search_for("product_id = \"#{@repo1.product.id}\"")
      assert_equal acss, [@simplified_acs]
    end

    def test_search_product_name
      acss = AlternateContentSource.search_for("product_name = \"#{@repo1.product.name}\"")
      assert_equal acss, [@simplified_acs]
    end
  end
end
