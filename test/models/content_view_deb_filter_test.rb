require 'katello_test_helper'

module Katello
  class ContentViewDebFilterTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      Repository.any_instance.stubs(:deb_count).returns(2)
      @repo = katello_repositories(:debian_9_amd64)

      @debian = katello_repositories(:debian_9_amd64)

      @deb = katello_debs(:one)
      @deb2 = katello_debs(:two)
      @deb3 = katello_debs(:three)
      @deb4 = Katello::Deb.new
      @deb4.update(:name => "four", :filename => "four_1.0-1_amd64.deb", :architecture => "all", :pulp_id => "four-uuid")

      @repo.debs = [@deb, @deb2, @deb3, @deb4]
    end

    def test_query_debs
      @filter = katello_content_view_filters(:simple_deb_filter)
      assert @filter
      @one_deb_rule = katello_content_view_deb_filter_rules(:one_deb_rule)
      assert @one_deb_rule
      matched_debs = @filter.query_debs(@debian, @one_deb_rule)
      assert matched_debs.length > 0
    end

    def test_rule_with_empty_string_arch_matched
      @filter = katello_content_view_filters(:simple_deb_filter)
      @one_deb_rule_empty_strings = katello_content_view_deb_filter_rules(:one_deb_rule_empty_strings)
      matched_debs = @filter.query_debs(@debian, @one_deb_rule_empty_strings)
      assert matched_debs.length > 0
    end

    def test_name_filter_generates_mongodb_condition_by_filename
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      @filter = FactoryBot.create(:katello_content_view_deb_filter)
      FactoryBot.create(:katello_content_view_deb_filter_rule, :filter => @filter, :name => "#{@deb.name}")

      expected = {"filename" => {"$in" => ["uno_1.0-1_amd64.deb"]}}
      assert_equal expected, @filter.generate_clauses(@repo)
    end

    def test_arch_filter_generates_mongodb_conditions_by_filename
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      @filter = FactoryBot.create(:katello_content_view_deb_filter)
      FactoryBot.create(:katello_content_view_deb_filter_rule, :filter => @filter, :name => "*",
                                   :architecture => @deb4.architecture)

      expected = {"filename" => { "$in" => [@deb4.filename] }}
      assert_equal expected, @filter.generate_clauses(@repo)
    end
  end
end
