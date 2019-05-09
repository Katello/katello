require 'katello_test_helper'

module Katello
  class Util::ErratumClauseGeneratorTest < ActiveSupport::TestCase
    INCLUDE_ALL_ERRATA = {"id" => {"$exists" => true}}.freeze

    def setup
      User.current = User.find(users(:admin).id)
      organization = get_organization
      Repository.any_instance.stubs(:package_count).returns(2)
      @repo = katello_repositories(:fedora_17_x86_64)
      @rpm = katello_rpms(:one)
      @rpm2 = katello_rpms(:two)
      @rpm3 = katello_rpms(:three)

      @repo.rpms = [@rpm, @rpm2, @rpm3]
      @repo.rpms.each do |rpm|
        rpm.version_sortable = Util::Package.sortable_version(rpm.version)
        rpm.release_sortable = Util::Package.sortable_version(rpm.release)
        rpm.save!
      end

      @content_view = FactoryBot.build(:katello_content_view, :organization => organization)
      @content_view.save!
      @content_view.repositories << @repo
      @from = Date.today - 5
      @to = Date.today
    end

    def test_errata_ids
      @filter = FactoryBot.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule,
                                    :filter => @filter, :errata_id => "Foo1")
      goo_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule,
                                    :filter => @filter, :errata_id => "Foo2")

      expected_errata = [erratum_arel[:errata_id].in(["Foo1", "Foo2"])]
      assert_errata_rules([foo_rule, goo_rule], expected_errata)
    end

    def test_errata_dates_default
      types = ["bugfix", "enhancement", "security"]

      @filter = FactoryBot.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule,
                                    :filter => @filter, :start_date => @from.to_s, :end_date => @to.to_s,
                                    :types => types)

      types_query = erratum_arel[:errata_type].in(types)
      date_query = erratum_arel[:updated].gteq(@from).and(erratum_arel[:updated].lteq(@to))

      expected = [date_query.and(types_query)]
      assert_errata_rules([foo_rule], expected)
    end

    def test_errata_dates_issued
      types = ["bugfix", "security"]

      @filter = FactoryBot.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule,
                                    :date_type => ContentViewErratumFilterRule::ISSUED,
                                    :filter => @filter, :start_date => @from.to_s, :end_date => @to.to_s,
                                    :types => types)

      types_query = erratum_arel[:errata_type].in(types)
      date_query = erratum_arel[:issued].gteq(@from).and(erratum_arel[:issued].lteq(@to))

      expected = [date_query.and(types_query)]
      assert_errata_rules([foo_rule], expected)
    end

    def test_errata_dates_updated
      types = ["security"]

      @filter = FactoryBot.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule,
                                    :date_type => ContentViewErratumFilterRule::UPDATED,
                                    :filter => @filter, :start_date => @from.to_s, :end_date => @to.to_s,
                                    :types => types)

      types_query = erratum_arel[:errata_type].in(types)
      date_query = erratum_arel[:updated].gteq(@from).and(erratum_arel[:updated].lteq(@to))

      expected = [date_query.and(types_query)]
      assert_errata_rules([foo_rule], expected)
    end

    def test_errata_types
      types = ["security", "bugfix"]

      @filter = FactoryBot.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule,
                                    :filter => @filter,
                                    :types => types)

      types_query = erratum_arel[:errata_type].in(types)
      expected = [types_query]
      assert_errata_rules([foo_rule], expected)
    end

    private

    def assert_errata_rules(rules, expected_errata_clauses)
      returned_errata = {'id' => {"$in" => ["foo", "bar"]}}

      clause_gen = setup_whitelist_filter(rules) do |gen|
        gen.expects(:errata_clauses_from_content).once.
                    returns(returned_errata).with do |clauses|
                      clauses.map(&:to_sql).must_equal(expected_errata_clauses.map(&:to_sql))
                    end
      end
      assert_equal returned_errata, clause_gen.copy_clause
      assert_nil clause_gen.remove_clause

      clause_gen = setup_blacklist_filter(rules) do |gen|
        gen.expects(:errata_clauses_from_content).once.
                    returns(returned_errata).with do |clauses|
                      clauses.map(&:to_sql).must_equal(expected_errata_clauses.map(&:to_sql))
                    end
      end
      expected = {"$and" => [INCLUDE_ALL_ERRATA, {"$nor" => [returned_errata]}]}

      assert_equal expected, clause_gen.copy_clause
      assert_equal returned_errata, clause_gen.remove_clause
    end

    def erratum_arel
      ::Katello::Erratum.arel_table
    end

    def array_to_struct(items)
      items.collect do |item|
        OpenStruct.new(item)
      end
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
      clause_gen = Util::ErratumClauseGenerator.new(@repo, [filter])
      yield clause_gen if block_given?
      clause_gen.generate
      clause_gen
    end
  end
end
