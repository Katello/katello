require 'katello_test_helper'

module Katello
  class Util::PackageClauseGeneratorTest < ActiveSupport::TestCase
    INCLUDE_ALL_PACKAGES = {"filename" => {"$exists" => true}}.freeze

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

      @content_view = FactoryGirl.build(:katello_content_view, :organization => organization)
      @content_view.save!
      @content_view.repositories << @repo
    end

    def test_package_names
      @filter = FactoryGirl.create(:katello_content_view_package_filter, :content_view => @content_view)
      foo_rule = FactoryGirl.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "#{@rpm.name[0..1]}*")
      goo_rule = FactoryGirl.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => @rpm2.name)

      combined = [{"filename" => {"$in" => [@rpm.filename, @rpm2.filename]}}]

      clause_gen = setup_whitelist_filter([foo_rule, goo_rule])
      expected = {"$or" => combined}
      assert_equal expected, clause_gen.copy_clause
      assert_nil clause_gen.remove_clause

      blacklist_expected = {"$or" => combined}
      clause_gen = setup_blacklist_filter([foo_rule, goo_rule])
      expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [blacklist_expected]}]}
      assert_equal expected, clause_gen.copy_clause
      assert_equal blacklist_expected, clause_gen.remove_clause
    end

    def test_package_versions
      @filter = FactoryGirl.create(:katello_content_view_package_filter, :content_view => @content_view)
      foo_rule = FactoryGirl.create(:katello_content_view_package_filter_rule, :filter => @filter,
                                    :name => @rpm2.name, :version => @rpm2.version)
      goo_rule = FactoryGirl.create(:katello_content_view_package_filter_rule, :filter => @filter,
                                    :name => "#{@rpm.name[0..1]}*", :min_version => "0.9", :max_version => "1.1")

      combined = [{"filename" => {"$in" => [@rpm.filename, @rpm2.filename]}}]

      clause_gen = setup_whitelist_filter([foo_rule, goo_rule])
      expected = {"$or" => combined}
      assert_equal deep_sort(expected), deep_sort(clause_gen.copy_clause)
      assert_nil clause_gen.remove_clause

      blacklist_expected = {"$or" => combined}
      clause_gen = setup_blacklist_filter([foo_rule, goo_rule])
      expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [blacklist_expected]}]}
      assert_equal deep_sort(expected), deep_sort(clause_gen.copy_clause)
      assert_equal deep_sort(blacklist_expected), deep_sort(clause_gen.remove_clause)
    end

    def deep_sort(obj)
      if obj.is_a?(Array)
        to_ret = obj.map { |value| deep_sort(value) }
        to_ret[0].is_a?(Hash) ? to_ret : to_ret.sort
      elsif obj.is_a?(Hash)
        obj.inject({}) do |hash, (key, value)|
          hash[key] = deep_sort(value)
          hash
        end
      else
        obj
      end
    end

    def test_package_group_names
      @filter = FactoryGirl.create(:katello_content_view_package_group_filter, :content_view => @content_view)
      foo_rule = FactoryGirl.create(:katello_content_view_package_group_filter_rule,
                                    :filter => @filter, :name => "foo*")
      goo_rule = FactoryGirl.create(:katello_content_view_package_group_filter_rule,
                                    :filter => @filter, :name => "goo*")

      expected_ids = @filter.package_group_rules.map(&:uuid)
      expected_group_clause = [{"_id" => {"$in" => expected_ids}}]
      returned_packages = {'names' => {"$in" => ["foo", "bar"]}}

      clause_gen = setup_whitelist_filter([foo_rule, goo_rule]) do |gen|
        gen.expects(:package_clauses_for_group).once.
                    with(expected_group_clause).returns(returned_packages)
      end
      assert_equal returned_packages, clause_gen.copy_clause
      assert_nil clause_gen.remove_clause

      clause_gen = setup_blacklist_filter([foo_rule, goo_rule]) do |gen|
        gen.expects(:package_clauses_for_group).once.
                    with(expected_group_clause).returns(returned_packages)
      end
      expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [returned_packages]}]}
      assert_equal expected, clause_gen.copy_clause
      assert_equal returned_packages, clause_gen.remove_clause
    end

    def test_errata_ids
      @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                    :filter => @filter, :errata_id => "Foo1")
      goo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                    :filter => @filter, :errata_id => "Foo2")

      expected_errata = [{"id" => {"$in" => ["Foo1", "Foo2"]}}]
      assert_errata_rules([foo_rule, goo_rule], expected_errata)
    end

    def test_errata_dates_default
      from = Date.today.to_s
      to = Date.today.to_s

      @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                    :filter => @filter, :start_date => from, :end_date => to)

      expected = [{"updated" => {"$gte" => from.to_time.as_json,
                                 "$lte" => to.to_time.as_json}}]
      assert_errata_rules([foo_rule], expected)
    end

    def test_errata_dates_issued
      from = Date.today.to_s
      to = Date.today.to_s

      @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                    :date_type => ContentViewErratumFilterRule::ISSUED,
                                    :filter => @filter, :start_date => from, :end_date => to)

      expected = [{"issued" => {"$gte" => from.to_time.as_json,
                                "$lte" => to.to_time.as_json}}]
      assert_errata_rules([foo_rule], expected)
    end

    def test_errata_dates_updated
      from = Date.today.to_s
      to = Date.today.to_s

      @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                    :date_type => ContentViewErratumFilterRule::UPDATED,
                                    :filter => @filter, :start_date => from, :end_date => to)

      expected = [{"updated" => {"$gte" => from.to_time.as_json,
                                 "$lte" => to.to_time.as_json}}]
      assert_errata_rules([foo_rule], expected)
    end

    def test_errata_types
      @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                    :filter => @filter, :types => [:bugfix, :security])

      expected = [{"type" => {"$in" => [:bugfix, :security]}}]
      assert_errata_rules([foo_rule], expected)
    end

    def test_errata_both
      from = Date.today
      to = Date.today

      @filter = FactoryGirl.create(:katello_content_view_erratum_filter, :content_view => @content_view)
      foo_rule = FactoryGirl.create(:katello_content_view_erratum_filter_rule,
                                    :filter => @filter, :start_date => from.to_s, :date_type => "issued",
                                    :end_date => to.to_s, :types => [:enhancement, :security])

      expected = [{"$and" => [{"issued" => {"$gte" => from.to_s.to_time.as_json,
                                            "$lte" => to.to_s.to_time.as_json}},
                              {"type" => {"$in" => [:enhancement, :security]}}]}]
      assert_errata_rules([foo_rule], expected)
    end

    def assert_errata_rules(rules, expected_errata)
      returned_packages = {'filenames' => {"$in" => ["foo", "bar"]}}

      clause_gen = setup_whitelist_filter(rules) do |gen|
        gen.expects(:package_clauses_for_errata).once.
                    with(expected_errata).returns(returned_packages)
      end
      assert_equal returned_packages, clause_gen.copy_clause
      assert_nil clause_gen.remove_clause

      clause_gen = setup_blacklist_filter(rules) do |gen|
        gen.expects(:package_clauses_for_errata).once.
                    with(expected_errata).returns(returned_packages)
      end
      expected = {"$and" => [INCLUDE_ALL_PACKAGES, {"$nor" => [returned_packages]}]}

      assert_equal expected, clause_gen.copy_clause
      assert_equal returned_packages, clause_gen.remove_clause
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
      clause_gen = Util::PackageClauseGenerator.new(@repo, [filter])
      yield clause_gen if block_given?
      clause_gen.generate
      clause_gen
    end
  end
end
