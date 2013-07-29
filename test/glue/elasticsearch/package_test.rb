#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'

class PackageTest < MiniTest::Rails::ActiveSupport::TestCase
  i_suck_and_my_tests_are_order_dependent!

  FIXTURES_FILE = File.join(Rails.root, "test", "fixtures", "elasticsearch", "packages.yml")

  def self.before_suite
    disable_glue_layers(["Pulp"], ["Package"]) # enable glue layers
    VCR.insert_cassette("glue_elasticsearch_package")
    Tire.index(Package.index).delete
    Tire.index Package.index do
      create :settings => Package.index_settings, :mappings => Package.index_mapping
    end
  end

  def setup
    @repo = Repository.new(:pulp_id => "abcrepo")
    @packages = YAML::load_file(FIXTURES_FILE).values.map(&:with_indifferent_access)
    @packages.each_with_index do |package, idx|
      package.merge!(:repoids => [@repo.pulp_id],
                     :sortable_version => Util::Package.sortable_version(package[:version]),
                     :sortable_release => Util::Package.sortable_version(package[:release])
                    )
    end

    packages = @packages.map(&:as_json)
    Tire.index Package.index do
      import packages
    end
    Tire.index(Package.index).refresh

    @all_ids = @packages.map { |pkg| pkg[:id] }.sort
  end

  def self.after_suite
    VCR.eject_cassette
  end

  def test_no_version_filter
    results = search_version_range
    assert_equal @all_ids, results.map(&:id).sort
  end

  def test_min_version_filter
    results = search_version_range("1.0.0")
    assert_equal ["abc123-4", "abc123-6"], results.map(&:id).sort

    results = search_version_range("1")
    expected = @all_ids - ["abc123-8"]
    assert_equal expected, results.map(&:id).sort

    results = search_version_range("1.0.0-1.0")
    expected = ["abc123-4", "abc123-6"]
    assert_equal expected, results.map(&:id).sort

    results = search_version_range("1.0.0-1el4")
    expected = ["abc123-1", "abc123-2", "abc123-4", "abc123-5", "abc123-6"]
    assert_equal expected, results.map(&:id).sort
  end

  def test_max_version_filter
    results = search_version_range(nil, "1:1.0.0")
    assert_equal @all_ids - ["abc123-2"], results.map(&:id).sort

    results = search_version_range(nil, "0:1.0.0")
    assert_equal ["abc123-8"], results.map(&:id).sort
  end

  def test_version_range_filter
    results = search_version_range("0.9.1", "2:0.9.1")
    assert_equal @all_ids, results.map(&:id).sort

    results = search_version_range("1.0.0", "1.0.0-0.9.1")
    assert_empty results

    results = search_version_range("1.0.0-1", "1.0.0-1.2")
    expected = ["abc123-1", "abc123-2", "abc123-5"]
    assert_equal expected, results.map(&:id).sort
  end


  # helper methods

  def search_version_range(min=nil, max=nil)
    filters = Util::Package.version_filter(min, max)
    filter_search(filters)
  end

  def filter_search(filters)
    Package.search("*", 0, @packages.length, [@repo.pulp_id], [:id, "ASC"], :all,
                   'name', filters)
  end
end
