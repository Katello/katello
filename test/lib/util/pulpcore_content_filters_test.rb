require 'katello_test_helper'

module Katello
  class Util::PulpcoreContentMetadataFileFilterTest < ActiveSupport::TestCase
    include RepositorySupport
    include Util::PulpcoreContentFilters

    def setup
      @metadata1_href = "/href1"
      @metadata2_href = "/href2"
      @metadatafiles_results = [
        PulpRpmClient::RpmRepoMetadataFile.new(:pulp_href => @metadata1_href),
        PulpRpmClient::RpmRepoMetadataFile.new(:pulp_href => @metadata2_href)
      ]
    end

    def test_filter_by_pulp_id_returns_every_metadata_pulp_href_with_empty_list_of_pulp_ids
      assert_equal [@metadata1_href, @metadata2_href], filter_metadatafiles_by_pulp_hrefs(@metadatafiles_results, [])
    end

    def test_filter_by_pulp_id_returns_nothing_with_empty_list_of_metadatafiles
      assert_equal [], filter_metadatafiles_by_pulp_hrefs([], ["/some/content/href"])
    end

    def test_filter_by_pulp_id_returns_every_metadata_pulp_href_with_any_package_pulp_id
      assert_equal [@metadata1_href, @metadata2_href], filter_metadatafiles_by_pulp_hrefs(@metadatafiles_results, ["/some/content/href"])
    end
  end

  class Util::PulpcoreContentDistributionTreeFilterTest < ActiveSupport::TestCase
    include RepositorySupport
    include Util::PulpcoreContentFilters

    def setup
      @distribution_tree1_href = "/href1"
      @distribution_tree2_href = "/href2"
      @distribution_trees_results = [
        PulpRpmClient::RpmDistributionTree.new(:pulp_href => @distribution_tree1_href),
        PulpRpmClient::RpmDistributionTree.new(:pulp_href => @distribution_tree2_href)
      ]
    end

    def test_filter_by_pulp_id_returns_every_distribution_tree_pulp_href_with_empty_list_of_pulp_ids
      assert_equal [@distribution_tree1_href, @distribution_tree2_href], filter_distribution_trees_by_pulp_hrefs(@distribution_trees_results, [])
    end

    def test_filter_by_pulp_id_returns_nothing_with_empty_list_of_distribution_trees
      assert_equal [], filter_distribution_trees_by_pulp_hrefs([], ["/some/content/href"])
    end

    def test_filter_by_pulp_id_returns_every_distribution_tree_pulp_href_with_any_package_pulp_id
      assert_equal [@distribution_tree1_href, @distribution_tree2_href], filter_distribution_trees_by_pulp_hrefs(@distribution_trees_results, ["/some/content/href"])
    end
  end

  class Util::PulpcoreContentPackageEnvironmentFilterTest < ActiveSupport::TestCase
    include RepositorySupport
    include Util::PulpcoreContentFilters

    def setup
      @packagegroup1_href = "/href1"
      @packagegroup2_href = "/href2"
      @packagegroup3_href = "/href3"

      @packageenv1 = PulpRpmClient::RpmPackageEnvironment.new(:pulp_href => "/env/href1",
                                                          :packagegroups => [@packagegroup1_href])
      @packageenv2 = PulpRpmClient::RpmPackageEnvironment.new(:pulp_href => "/env/href2",
                                                          :packagegroups => [@packagegroup2_href])
    end

    def test_filter_by_pulp_id_returns_empty_list_with_empty_package_group_list
      assert_equal [], filter_package_environments_by_pulp_hrefs([@packageenv1, @packageenv2], [])
    end

    def test_filter_by_pulp_id_returns_nothing_with_empty_list_of_package_environments
      assert_equal [], filter_package_environments_by_pulp_hrefs([], [@packagegroup1_href])
    end

    def test_filter_by_pulp_id_returns_every_metadata_pulp_href_with_a_matching_package_group
      assert_equal [@packageenv1.pulp_href], filter_package_environments_by_pulp_hrefs([@packageenv1, @packageenv2], [@packagegroup1_href])
    end

    def test_filter_by_pulp_id_returns_nothing_if_no_package_group_matches
      assert_equal [], filter_package_environments_by_pulp_hrefs([@packageenv1, @packageenv2], [@packagegroup3_href])
    end
  end

  class Util::PulpcoreContentPackageGroupFilterTest < ActiveSupport::TestCase
    include RepositorySupport
    include Util::PulpcoreContentFilters

    def setup
      @rpm1 = katello_rpms(:one)
      @rpm2 = katello_rpms(:two)
      @rpm3 = katello_rpms(:three)

      @package_group = katello_package_groups(:mammals_pg)
      @package_group.stubs(:package_names).returns([@rpm2.name, @rpm3.name])
    end

    def test_filter_by_pulp_id_returns_no_package_groups_with_empty_package_href_list
      assert_equal [], filter_package_groups_by_pulp_href([@package_group], [])
    end

    def test_filter_by_pulp_id_returns_nothing_with_empty_list_of_package_groups
      assert_equal [], filter_package_groups_by_pulp_href([], [@rpm2.pulp_id])
    end

    def test_filter_by_pulp_id_returns_every_package_group_pulp_href_with_a_matching_package_href
      assert_equal [@package_group], filter_package_groups_by_pulp_href([@package_group], [@rpm2.pulp_id])
    end

    def test_filter_by_pulp_id_returns_nothing_if_no_package_group_matches
      assert_equal [], filter_package_groups_by_pulp_href([@package_group], [@packagegroup3_href])
    end
  end
end
