require 'katello_test_helper'

module Katello
  class ContentViewPackageFilterTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      Repository.any_instance.stubs(:package_count).returns(2)
      @repo = katello_repositories(:fedora_17_x86_64)

      @fedora = katello_repositories(:fedora_17_x86_64)

      @rpm = katello_rpms(:one)
      @rpm2 = katello_rpms(:two)
      @rpm3 = katello_rpms(:three)
      @rpm4 = Katello::Rpm.new
      @rpm4.update(:name => "four", :filename => "four-1.1.rpm", :arch => "i386", :pulp_id => "four-uuid")
      @rpm5 = Katello::Rpm.new
      @rpm5.update(:name => "five", :filename => "five-1.1.rpm", :version => 2.0, :epoch => 0, :pulp_id => "five-uuid")

      @srpm = Katello::Srpm.new(:name => "srpm1", :filename => "one-1.1.srpm", :version => 2.0, :epoch => 0, :pulp_id => "one-srpm-uuid")
      @repo.srpms = [@srpm]

      @repo.rpms = [@rpm, @rpm2, @rpm3, @rpm4, @rpm5]
      @repo.rpms.each do |rpm|
        rpm.version_sortable = Util::Package.sortable_version(rpm.version)
        rpm.release_sortable = Util::Package.sortable_version(rpm.release)
        rpm.save!
      end
    end

    def test_query_rpms
      @filter = katello_content_view_filters(:simple_filter)
      @one_package_rule = katello_content_view_package_filter_rules(:one_package_rule)
      matched_rpms = @filter.query_rpms(@fedora, @one_package_rule)
      assert matched_rpms.length > 0

      all_applicable_rpms = @filter.applicable_repos.map(&:rpms).flatten.pluck(:filename)
      matched_rpms.each do |rpm|
        assert_includes all_applicable_rpms, rpm
      end
    end

    def test_rule_with_empty_string_arch_matched
      @filter = katello_content_view_filters(:simple_filter)
      @one_package_rule_empty_strings = katello_content_view_package_filter_rules(:one_package_rule_empty_strings)
      matched_rpms = @filter.query_rpms(@fedora, @one_package_rule_empty_strings)
      assert matched_rpms.length > 0
    end

    def test_name_filter_generates_mongodb_condition_by_filename
      @filter = FactoryBot.create(:katello_content_view_package_filter)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "#{@rpm.name[0..1]}*")

      expected = {"filename" => {"$in" => ["one-1.1.rpm"]}}
      assert_equal expected, @filter.generate_clauses(@repo)
    end

    def test_name_filter_generates_pulpcore_hrefs_by_filename
      @filter = FactoryBot.create(:katello_content_view_package_filter)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "#{@rpm.name[0..1]}*")

      assert_equal [@rpm.pulp_id], @filter.content_unit_pulp_ids(@repo)
    end

    def test_arch_filter_generates_mongodb_conditions_by_filename
      @filter = FactoryBot.create(:katello_content_view_package_filter)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "*",
                                   :architecture => @rpm4.arch)

      expected = {"filename" => { "$in" => [@rpm4.filename] }}
      assert_equal expected, @filter.generate_clauses(@repo)
    end

    def test_arch_filter_generates_pulpcore_hrefs
      @filter = FactoryBot.create(:katello_content_view_package_filter)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "*",
                                   :architecture => @rpm4.arch)

      assert_equal [@rpm4.pulp_id], @filter.content_unit_pulp_ids(@repo)
    end

    def test_version_filter_generates_mongodb_conditions_by_filename
      @filter = FactoryBot.create(:katello_content_view_package_filter)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "*",
                                   :version => 2.0)

      expected = {"filename" => { "$in" => [@rpm5.filename] }}
      assert_equal expected, @filter.generate_clauses(@repo)
    end

    def test_version_filter_generates_pulpcore_hrefs
      @filter = FactoryBot.create(:katello_content_view_package_filter)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "*",
                                   :version => 2.0)

      assert_equal [@rpm5.pulp_id], @filter.content_unit_pulp_ids(@repo)
    end

    def test_version_range_filter_generates_mongodb_conditions_by_filename
      @filter = FactoryBot.create(:katello_content_view_package_filter)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "*",
                                   :min_version => 1.5, :max_version => 3.0)

      expected = {"filename" => { "$in" => [@rpm5.filename] }}
      assert_equal expected, @filter.generate_clauses(@repo)
    end

    def test_version_range_filter_generates_pulpcore_hrefs
      @filter = FactoryBot.create(:katello_content_view_package_filter)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "*",
                                   :min_version => 1.5, :max_version => 3.0)

      assert_equal [@rpm5.pulp_id], @filter.content_unit_pulp_ids(@repo)
    end
  end
end
