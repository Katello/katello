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

    def test_version_filter_without_epoch_matches_all_epochs
      # Test that when epoch is not specified, it matches packages with any epoch
      openssl_epoch0 = katello_rpms(:openssl_epoch0)
      openssl_epoch1 = katello_rpms(:openssl_epoch1)
      @repo.rpms << [openssl_epoch0, openssl_epoch1]
      @repo.rpms.each do |rpm|
        rpm.version_sortable = Util::Package.sortable_version(rpm.version)
        rpm.release_sortable = Util::Package.sortable_version(rpm.release)
        rpm.save!
      end

      @filter = FactoryBot.create(:katello_content_view_package_filter)
      # Filter for version 3.2.2 without specifying epoch
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "openssl",
                                   :version => "3.2.2")

      matched_pulp_ids = @filter.content_unit_pulp_ids(@repo)
      # Should match both epoch 0 and epoch 1
      assert_includes matched_pulp_ids, openssl_epoch0.pulp_id
      assert_includes matched_pulp_ids, openssl_epoch1.pulp_id
    end

    def test_version_filter_with_explicit_epoch_matches_only_that_epoch
      # Test that when epoch is explicitly specified, it only matches that epoch
      openssl_epoch0 = katello_rpms(:openssl_epoch0)
      openssl_epoch1 = katello_rpms(:openssl_epoch1)
      @repo.rpms << [openssl_epoch0, openssl_epoch1]
      @repo.rpms.each do |rpm|
        rpm.version_sortable = Util::Package.sortable_version(rpm.version)
        rpm.release_sortable = Util::Package.sortable_version(rpm.release)
        rpm.save!
      end

      @filter = FactoryBot.create(:katello_content_view_package_filter)
      # Filter for version 1:3.2.2 (explicitly specifying epoch 1)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "openssl",
                                   :version => "1:3.2.2")

      matched_pulp_ids = @filter.content_unit_pulp_ids(@repo)
      # Should only match epoch 1
      refute_includes matched_pulp_ids, openssl_epoch0.pulp_id
      assert_includes matched_pulp_ids, openssl_epoch1.pulp_id
    end

    def test_version_filter_with_epoch_zero_specified_matches_only_epoch_zero
      # Test that when epoch 0 is explicitly specified, it only matches epoch 0
      openssl_epoch0 = katello_rpms(:openssl_epoch0)
      openssl_epoch1 = katello_rpms(:openssl_epoch1)
      @repo.rpms << [openssl_epoch0, openssl_epoch1]
      @repo.rpms.each do |rpm|
        rpm.version_sortable = Util::Package.sortable_version(rpm.version)
        rpm.release_sortable = Util::Package.sortable_version(rpm.release)
        rpm.save!
      end

      @filter = FactoryBot.create(:katello_content_view_package_filter)
      # Filter for version 0:3.2.2 (explicitly specifying epoch 0)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "openssl",
                                   :version => "0:3.2.2")

      matched_pulp_ids = @filter.content_unit_pulp_ids(@repo)
      # Should only match epoch 0
      assert_includes matched_pulp_ids, openssl_epoch0.pulp_id
      refute_includes matched_pulp_ids, openssl_epoch1.pulp_id
    end

    def test_version_filter_greater_than_without_epoch
      # Test that comparison operators work without epoch specified
      # "version > 3.2.1" should use epoch 0 for comparison
      openssl_epoch0 = katello_rpms(:openssl_epoch0)
      openssl_epoch1 = katello_rpms(:openssl_epoch1)
      openssl_epoch1_diff = katello_rpms(:openssl_epoch1_diff_version)
      @repo.rpms << [openssl_epoch0, openssl_epoch1, openssl_epoch1_diff]
      @repo.rpms.each do |rpm|
        rpm.version_sortable = Util::Package.sortable_version(rpm.version)
        rpm.release_sortable = Util::Package.sortable_version(rpm.release)
        rpm.save!
      end

      @filter = FactoryBot.create(:katello_content_view_package_filter)
      # min_version > 3.2.1 without epoch (defaults to epoch 0)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "openssl",
                                   :min_version => "3.2.1")

      matched_pulp_ids = @filter.content_unit_pulp_ids(@repo)
      # Should match openssl_epoch0 (0:3.2.2 > 0:3.2.1) and both epoch 1 packages (epoch 1 > epoch 0)
      assert_includes matched_pulp_ids, openssl_epoch0.pulp_id
      assert_includes matched_pulp_ids, openssl_epoch1.pulp_id
      assert_includes matched_pulp_ids, openssl_epoch1_diff.pulp_id
    end

    def test_version_filter_greater_than_with_epoch
      # Test that comparison operators work with epoch specified
      # "version > 1:3.2.1" should only match packages with epoch 1 and version > 3.2.1
      openssl_epoch0 = katello_rpms(:openssl_epoch0)
      openssl_epoch1 = katello_rpms(:openssl_epoch1)
      openssl_epoch1_diff = katello_rpms(:openssl_epoch1_diff_version)
      @repo.rpms << [openssl_epoch0, openssl_epoch1, openssl_epoch1_diff]
      @repo.rpms.each do |rpm|
        rpm.version_sortable = Util::Package.sortable_version(rpm.version)
        rpm.release_sortable = Util::Package.sortable_version(rpm.release)
        rpm.save!
      end

      @filter = FactoryBot.create(:katello_content_view_package_filter)
      # min_version > 1:3.2.1 (explicitly epoch 1)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "openssl",
                                   :min_version => "1:3.2.1")

      matched_pulp_ids = @filter.content_unit_pulp_ids(@repo)
      # Should NOT match epoch 0 (epoch 0 < epoch 1)
      refute_includes matched_pulp_ids, openssl_epoch0.pulp_id
      # Should match openssl_epoch1 (1:3.2.2 > 1:3.2.1)
      assert_includes matched_pulp_ids, openssl_epoch1.pulp_id
      # Should NOT match openssl_epoch1_diff (1:3.2.1 is not > 1:3.2.1)
      refute_includes matched_pulp_ids, openssl_epoch1_diff.pulp_id
    end

    def test_version_filter_less_than_without_epoch
      # Test that less than operator works without epoch specified
      openssl_epoch0 = katello_rpms(:openssl_epoch0)
      openssl_epoch1 = katello_rpms(:openssl_epoch1)
      openssl_epoch1_diff = katello_rpms(:openssl_epoch1_diff_version)
      @repo.rpms << [openssl_epoch0, openssl_epoch1, openssl_epoch1_diff]
      @repo.rpms.each do |rpm|
        rpm.version_sortable = Util::Package.sortable_version(rpm.version)
        rpm.release_sortable = Util::Package.sortable_version(rpm.release)
        rpm.save!
      end

      @filter = FactoryBot.create(:katello_content_view_package_filter)
      # max_version < 3.2.2 without epoch (defaults to epoch 0)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "openssl",
                                   :max_version => "3.2.2")

      matched_pulp_ids = @filter.content_unit_pulp_ids(@repo)
      # Should NOT match openssl_epoch0 (0:3.2.2 is not < 0:3.2.2)
      refute_includes matched_pulp_ids, openssl_epoch0.pulp_id
      # Should NOT match epoch 1 packages (epoch 1 > epoch 0)
      refute_includes matched_pulp_ids, openssl_epoch1.pulp_id
      refute_includes matched_pulp_ids, openssl_epoch1_diff.pulp_id
    end

    def test_version_filter_less_than_with_explicit_epoch
      # Test that less than operator works with epoch specified
      openssl_epoch0 = katello_rpms(:openssl_epoch0)
      openssl_epoch1 = katello_rpms(:openssl_epoch1)
      openssl_epoch1_diff = katello_rpms(:openssl_epoch1_diff_version)
      @repo.rpms << [openssl_epoch0, openssl_epoch1, openssl_epoch1_diff]
      @repo.rpms.each do |rpm|
        rpm.version_sortable = Util::Package.sortable_version(rpm.version)
        rpm.release_sortable = Util::Package.sortable_version(rpm.release)
        rpm.save!
      end

      @filter = FactoryBot.create(:katello_content_view_package_filter)
      # max_version < 1:3.2.2 (explicitly epoch 1)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => @filter, :name => "openssl",
                                   :max_version => "1:3.2.2")

      matched_pulp_ids = @filter.content_unit_pulp_ids(@repo)
      # Should match epoch 0 (epoch 0 < epoch 1)
      assert_includes matched_pulp_ids, openssl_epoch0.pulp_id
      # Should NOT match openssl_epoch1 (1:3.2.2 is not < 1:3.2.2)
      refute_includes matched_pulp_ids, openssl_epoch1.pulp_id
      # Should match openssl_epoch1_diff (1:3.2.1 < 1:3.2.2)
      assert_includes matched_pulp_ids, openssl_epoch1_diff.pulp_id
    end
  end
end
