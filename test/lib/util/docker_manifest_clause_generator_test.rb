require 'katello_test_helper'

module Katello
  class Util::DockerManifestClauseGeneratorTest < ActiveSupport::TestCase
    INCLUDE_ALL_TAGS = {"name" => {"$exists" => true}}.freeze

    def setup
      User.current = User.find(users(:admin).id)
      organization = get_organization
      Repository.any_instance.stubs(:docker_manifest_count).returns(3)
      @repo = katello_repositories(:busybox)
      @tag1 = katello_docker_tags(:one)
      @tag2 = katello_docker_tags(:two)
      @tag3 = katello_docker_tags(:three)
      @man1 = katello_docker_manifests(:one)
      @man2 = katello_docker_manifests(:two)
      @man3 = katello_docker_manifests(:three)

      @tag1.update_attributes!(:pulp_id => "100011")
      @tag2.update_attributes!(:pulp_id => "100012")
      @tag3.update_attributes!(:pulp_id => "100013")

      @repo.docker_tags = [@tag1, @tag2, @tag3]
      @repo.docker_manifests = [@man1, @man2, @man3]
      @man1.docker_tags = [@tag1]
      @man1.save!
      @man2.docker_tags = [@tag2]
      @man2.save!
      @man3.docker_tags = [@tag3]
      @man3.save!

      @content_view = FactoryBot.build(:katello_content_view, :organization => organization)
      @content_view.save!
      @content_view.repositories << @repo
    end

    def test_include_names
      @filter = FactoryBot.create(:katello_content_view_docker_filter, :content_view => @content_view)
      rule1 = FactoryBot.create(:katello_content_view_docker_filter_rule, :filter => @filter, :name => @tag1.name)
      rule2 = FactoryBot.create(:katello_content_view_docker_filter_rule, :filter => @filter, :name => @tag2.name)

      clause_gen = setup_whitelist_filter([rule1, rule2])
      expected = {"$or" => [{"_id" => {"$in" => [@tag1.pulp_id, @tag2.pulp_id]}}]}
      assert_equal expected, clause_gen.copy_clause
      assert_nil clause_gen.remove_clause

      blacklist_expected = {"$or" => [{"_id" => {"$in" => [@tag1.pulp_id, @tag2.pulp_id]}}]}
      clause_gen = setup_blacklist_filter([rule1, rule2])
      expected = {"$and" => [INCLUDE_ALL_TAGS, {"$nor" => [blacklist_expected]}]}
      assert_equal expected, clause_gen.copy_clause
      assert_equal blacklist_expected, clause_gen.remove_clause
    end

    def setup_whitelist_filter(filter_rules, &block)
      setup_filter_clause(true, filter_rules, &block)
    end

    def setup_blacklist_filter(filter_rules, &block)
      setup_filter_clause(false, filter_rules, &block)
    end

    def setup_filter_clause(inclusion, filter_rules, &_block)
      filter = filter_rules.first.filter
      filter.inclusion = inclusion
      filter.save!
      clause_gen = Util::DockerManifestClauseGenerator.new(@repo, [filter])
      yield clause_gen if block_given?
      clause_gen.generate
      clause_gen
    end
  end
end
