require 'katello_test_helper'

module Katello
  class Util::ErrataFilterByPulpHref < ActiveSupport::TestCase
    include Katello::Pulp3Support
    include Util::Errata

    def setup
      @mock_smart_proxy = mock('smart_proxy')
      @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
      @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
      @mock_smart_proxy.stubs(:pulp_primary?).returns(true)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo_service = @repo.backend_service(@mock_smart_proxy)

      @fedora_one = katello_rpms(:one)
      @fedora_one.pulp_id = "one-uuid"
      @fedora_one.filename = "packages/f/one-1.1.rpm"
      @fedora_two = katello_rpms(:two)
      @fedora_two.pulp_id = "two-uuid"
      @fedora_two.filename = "packages/f/two-1.1.rpm"
      @fedora_three = katello_rpms(:three)
      @fedora_three.pulp_id = "three-uuid"
      @fedora_three.filename = "pacakges/f/three-1.1.rpm"

      @repo.rpms = [@fedora_one, @fedora_two]
      @erratum = Katello::Erratum.new(:errata_id => "test_errata", :pulp_id => "dunno")
      erratum_package_one = Katello::ErratumPackage.new(:filename => "one-1.1.rpm", :nvrea => "one", :name => "one")
      erratum_package_two = Katello::ErratumPackage.new(:filename => "two-1.1.rpm", :nvrea => "two", :name => "two")
      @erratum.packages = [erratum_package_one, erratum_package_two]
      @erratum.save!

      @erratum2 = Katello::Erratum.new(:errata_id => "test_errata2", :pulp_id => "whatevs")
      erratum2_package_three = Katello::ErratumPackage.new(:filename => "three-1.1.rpm", :nvrea => "three", :name => "three")
      @erratum2.packages = [erratum2_package_three]
      @erratum2.save!

      @empty_erratum = Katello::Erratum.create(:errata_id => "empty", :pulp_id => "empty")

      @modular_erratum = katello_errata(:modular)
      @modular_rpm = katello_rpms(:modular_with_erratum_package)
      @modular_erratum_package = @modular_erratum.packages.first
      @module_stream = @modular_erratum_package.module_streams.first
    end

    # https://projects.theforeman.org/issues/35614
    def test_filter_by_pulp_href_excludes_errata_with_missing_module_streams
      # If the erratum's modular RPM count is no longer 1, the test no longer makes sense.
      # Ensure that all modular packages are accounted for in the final assertion.
      # The same goes for the number of module streams that the single RPM belongs to.
      assert_equal 1, @modular_erratum.packages.count
      assert_equal 1, @modular_erratum_package.module_streams.count
      assert_equal [@erratum], filter_errata_by_pulp_href([@modular_erratum, @erratum],
                                                          [@fedora_one.pulp_id, @fedora_two.pulp_id, @modular_rpm.pulp_id],
                                                          [@fedora_one.filename, @fedora_two.filename, @modular_erratum_package.filename],
                                                          [@module_stream.module_spec])
    end

    # https://projects.theforeman.org/issues/35614
    def test_filter_by_pulp_href_includes_errata_with_proper_module_streams
      # If the erratum's modular RPM count is no longer 1, the test no longer makes sense.
      # Ensure that all modular packages are accounted for in the final assertion.
      # The same goes for the number of module streams that the single RPM belongs to.
      assert_equal 1, @modular_erratum.packages.count
      assert_equal 1, @modular_erratum_package.module_streams.count
      assert_equal [@erratum, @modular_erratum].sort, filter_errata_by_pulp_href([@modular_erratum, @erratum],
                                                          [@fedora_one.pulp_id, @fedora_two.pulp_id, @modular_rpm.pulp_id, @module_stream.pulp_id],
                                                          [@fedora_one.filename, @fedora_two.filename, @modular_erratum_package.filename],
                                                          [@module_stream.module_spec])
    end

    def test_filter_by_pulp_id_returns_nothing_with_empty_list_of_pulp_ids
      assert_empty filter_errata_by_pulp_href([@erratum, @erratum2], [], [@fedora_one.filename, @fedora_two.filename], [])
    end

    def test_filter_by_pulp_id_returns_nothing_with_empty_list_of_errata
      assert_empty filter_errata_by_pulp_href([], [@fedora_one.pulp_id], [@fedora_one.filename, @fedora_two.filename], [])
    end

    # "Proper" errata here means errata with no RPMs that exist in its source repo and any empty errata.
    def test_filter_by_pulp_id_returns_proper_errata_if_no_matching_packages
      assert_equal [@erratum2, @empty_erratum].sort, filter_errata_by_pulp_href([@erratum, @erratum2, @empty_erratum], ["floop"], [@fedora_one.filename, @fedora_two.filename], []).sort
    end

    def test_filter_by_pulp_id_returns_proper_errata_with_some_matching_packages
      assert_equal [@erratum2, @empty_erratum].sort, filter_errata_by_pulp_href([@erratum, @erratum2, @empty_erratum], [@fedora_one.pulp_id], [@fedora_one.filename, @fedora_two.filename], []).sort
    end

    def test_filter_by_pulp_id_identifies_errata_with_all_matching_packages
      assert_equal [@erratum, @erratum2, @empty_erratum].sort, filter_errata_by_pulp_href([@erratum, @erratum2, @empty_erratum],
        [@fedora_one.pulp_id, @fedora_two.pulp_id],
        [@fedora_one.filename, @fedora_two.filename], []).sort
    end

    def test_filter_by_pulp_id_includes_errata_with_missing_packages_not_in_source_repo
      ::Katello::ErratumPackage.create(erratum_id: @erratum.id,
                                       nvrea: '999:missing-package-1.0.el27.noarch',
                                       name: 'missing-package',
                                       filename: 'missing-package-1.0.el27.noarch.rpm')
      assert_equal [@erratum, @erratum2, @empty_erratum].sort, filter_errata_by_pulp_href([@erratum, @erratum2, @empty_erratum],
                                                          [@fedora_one.pulp_id, @fedora_two.pulp_id],
                                                          [@fedora_one.filename, @fedora_two.filename], []).sort
    end
  end
end
