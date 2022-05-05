require 'katello_test_helper'

module Katello
  class Util::DebClauseGeneratorTest < ActiveSupport::TestCase
    INCLUDE_ALL_DEBS = {"name" => {"$exists" => true}}.freeze

    def setup
      User.current = User.find(users(:admin).id)
      organization = get_organization
      Repository.any_instance.stubs(:deb_count).returns(3)
      @repo = katello_repositories(:debian_9_amd64)
      @deb = katello_debs(:one)
      @deb2 = katello_debs(:two)
      @deb3 = katello_debs(:three)

      @repo.debs = [@deb, @deb2, @deb3]

      @content_view = FactoryBot.build(:katello_content_view, :organization => organization)
      @content_view.save!
      @content_view.repositories << @repo
    end

    def test_include_names
      @filter = FactoryBot.create(:katello_content_view_deb_filter, :content_view => @content_view)
      rule1 = FactoryBot.create(:katello_content_view_deb_filter_rule, :filter => @filter, :name => @deb.name)
      rule2 = FactoryBot.create(:katello_content_view_deb_filter_rule, :filter => @filter, :name => @deb2.name)

      clause_gen = setup_whitelist_filter([rule1, rule2])
      expected = {"$or" => [{"filename" => {"$in" => [@deb.filename, @deb2.filename]}}]}
      assert_equal expected, clause_gen.copy_clause
      assert_nil clause_gen.remove_clause

      blacklist_expected = {"$or" => [{"filename" => {"$in" => [@deb.filename, @deb2.filename]}}]}
      clause_gen = setup_blacklist_filter([rule1, rule2])
      expected = {"$and" => [INCLUDE_ALL_DEBS, {"$nor" => [blacklist_expected]}]}
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
      clause_gen = Util::DebClauseGenerator.new(@repo, [filter])
      yield clause_gen if block_given?
      clause_gen.generate
      clause_gen
    end
  end
end
