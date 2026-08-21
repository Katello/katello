require 'katello_test_helper'

module Katello
  class ContentViewEnvironmentTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @content_facet = katello_content_facets(:content_facet_one)
    end

    def test_activation_keys
      cvenv = katello_content_view_environments(:library_dev_view_library)
      ak = katello_activation_keys(:simple_key)
      ak.update!(content_view_environments: [cvenv])
      cvenv = Katello::ContentViewEnvironment.where(cvenv.slice(:environment_id, :content_view_id)).first
      assert_includes cvenv.activation_keys, ak
    end

    def test_for_content_facets
      cvenv = @content_facet.content_view_environments.first
      assert_includes ContentViewEnvironment.for_content_facets(@content_facet), cvenv
    end

    def test_hosts
      library = katello_environments(:library)
      view = katello_content_views(:library_dev_view)
      host = FactoryBot.create(:host, :with_content, :content_view => view,
                                       :lifecycle_environment => library)
      cvenv = Katello::ContentViewEnvironment.where(:environment_id => library, :content_view_id => view).first

      assert_includes cvenv.hosts, host
    end

    def test_with_label_and_org
      dev = katello_environments(:dev)
      view = katello_content_views(:library_dev_view)
      cvenv = Katello::ContentViewEnvironment.where(:environment_id => dev, :content_view_id => view).first
      assert_equal cvenv, ContentViewEnvironment.with_label_and_org('published_dev_view_dev', organization: dev.organization)
    end

    def test_fetch_content_view_environments_labels
      dev = katello_environments(:dev)
      view = katello_content_views(:library_dev_view)
      cvenv = Katello::ContentViewEnvironment.where(:environment_id => dev, :content_view_id => view).first
      assert_equal [cvenv], ContentViewEnvironment.fetch_content_view_environments(labels: ['published_dev_view_dev'], organization: dev.organization)
    end

    def test_fetch_content_view_environments_ids
      dev = katello_environments(:dev)
      view = katello_content_views(:library_dev_view)
      cvenv = Katello::ContentViewEnvironment.where(:environment_id => dev, :content_view_id => view).first
      assert_equal [cvenv], ContentViewEnvironment.fetch_content_view_environments(ids: [cvenv.id], organization: dev.organization)
    end

    def test_fetch_content_view_environments_invalid_ids_does_not_mutate_array
      dev = katello_environments(:dev)
      input_ids = [0, 999]
      assert_raises(HttpErrors::UnprocessableEntity) do
        ContentViewEnvironment.fetch_content_view_environments(ids: input_ids, organization: dev.organization)
      end
      assert_equal [0, 999], input_ids # should not have a map! which mutates the input array
    end

    def test_fetch_content_view_environments_mixed_validity_labels
      dev = katello_environments(:dev)
      assert_raises(HttpErrors::UnprocessableEntity) do
        ContentViewEnvironment.fetch_content_view_environments(labels: ['published_dev_view_dev, bogus'], organization: dev.organization)
      end
    end

    def test_fetch_content_view_environments_mixed_validity_ids
      dev = katello_environments(:dev)
      view = katello_content_views(:library_dev_view)
      cvenv = Katello::ContentViewEnvironment.where(:environment_id => dev, :content_view_id => view).first
      assert_raises(HttpErrors::UnprocessableEntity) do
        ContentViewEnvironment.fetch_content_view_environments(ids: [cvenv.id, 9999], organization: dev.organization)
      end
    end

    def test_fetch_content_view_environments_deduplicates_labels
      dev = katello_environments(:dev)
      view = katello_content_views(:library_dev_view)
      cvenv = Katello::ContentViewEnvironment.where(:environment_id => dev, :content_view_id => view).first
      result = ContentViewEnvironment.fetch_content_view_environments(
        labels: ['published_dev_view_dev', 'published_dev_view_dev'],
        organization: dev.organization
      )
      assert_equal [cvenv], result
    end

    def test_fetch_content_view_environments_deduplicates_ids
      dev = katello_environments(:dev)
      view = katello_content_views(:library_dev_view)
      cvenv = Katello::ContentViewEnvironment.where(:environment_id => dev, :content_view_id => view).first
      result = ContentViewEnvironment.fetch_content_view_environments(
        ids: [cvenv.id, cvenv.id],
        organization: dev.organization
      )
      assert_equal [cvenv], result
    end

    def test_fetch_content_view_environments_preserves_order_when_deduplicating
      org = katello_environments(:dev).organization
      cvenv1 = katello_content_view_environments(:library_dev_view_dev)
      cvenv2 = katello_content_view_environments(:library_dev_staging_view_dev)
      result = ContentViewEnvironment.fetch_content_view_environments(
        ids: [cvenv1.id, cvenv2.id, cvenv1.id],
        organization: org
      )
      assert_equal [cvenv1, cvenv2], result
    end
  end
end
