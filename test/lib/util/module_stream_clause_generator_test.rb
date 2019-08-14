require 'katello_test_helper'

module Katello
  class Util::ModuleStreamClauseGeneratorTest < ActiveSupport::TestCase
    INCLUDE_ALL_MODULE_STREAMS = {"_id" => {"$exists" => true}}.freeze

    def setup
      User.current = User.find(users(:admin).id)
      organization = get_organization
      Repository.any_instance.stubs(:package_count).returns(2)
      @repo = katello_repositories(:fedora_17_x86_64)
      @module_stream1 = katello_module_streams(:one)
      @module_stream2 = katello_module_streams(:two)
      @module_stream3 = katello_module_streams(:three)

      @repo.module_streams = [@module_stream1, @module_stream2, @module_stream3]
      @repo.save!
      @content_view = FactoryBot.build(:katello_content_view, :organization => organization)
      @content_view.save!
      @content_view.repositories << @repo
    end

    def test_module_streams
      @filter = FactoryBot.create(:katello_content_view_module_stream_filter, :content_view => @content_view)
      foo_rule = FactoryBot.create(:katello_content_view_module_stream_filter_rule,
                                   :filter => @filter,
                                   :name => @module_stream1.name,
                                   :stream => @module_stream1.stream)

      goo_rule = FactoryBot.create(:katello_content_view_module_stream_filter_rule,
                                   :filter => @filter,
                                   :name => @module_stream2.name,
                                   :stream => @module_stream2.stream)

      combined = {"_id" => {"$in" => [@module_stream1.pulp_id, @module_stream2.pulp_id]}}

      clause_gen = setup_whitelist_filter([foo_rule, goo_rule])
      expected = combined
      assert_equal expected, clause_gen.copy_clause
      assert_nil clause_gen.remove_clause

      blacklist_expected = combined
      clause_gen = setup_blacklist_filter([foo_rule, goo_rule])
      expected = {"$and" => [INCLUDE_ALL_MODULE_STREAMS, {"$nor" => [blacklist_expected]}]}
      assert_equal expected, clause_gen.copy_clause
      assert_equal blacklist_expected, clause_gen.remove_clause
    end

    private

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
      clause_gen = Util::ModuleStreamClauseGenerator.new(@repo, [filter])
      yield clause_gen if block_given?
      clause_gen.generate
      clause_gen
    end
  end
end
