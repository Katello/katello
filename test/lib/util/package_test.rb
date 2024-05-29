require 'katello_test_helper'

module Katello
  class Util::PackageTest < ActiveSupport::TestCase
    def test_sortable_version
      # Examples pulled from Pulp documentation
      # http://pulp-rpm-dev-guide.readthedocs.org/en/latest/sort-index.html
      assert_equal "01-3.01-9", Util::Package.sortable_version("3.9")
      assert_equal "01-3.02-10", Util::Package.sortable_version("3.10")
      assert_equal "01-5.03-256", Util::Package.sortable_version("5.256")
      assert_equal "01-1.01-1.$a", Util::Package.sortable_version("1.1a")
      assert_equal "01-1.$a", Util::Package.sortable_version("1.a+")
      assert_equal "02-12.$a.01-3.$bc", Util::Package.sortable_version("12a3bc")
      assert_equal "01-2.$xFg.02-33.$f.01-5", Util::Package.sortable_version("2xFg33.+f.5")
    end

    def test_latest_packages
      packages = [
        # This should be the latest
        {:epoch => '10', :version => '3.10', :release => '3.10'},
        # Make sure epoch has priority over version and release
        # and 2-digit epoch is handled properly
        {:epoch => '9', :version => '4', :release => '4'},
        # Make sure version has priority over release
        {:epoch => '10', :version => '2', :release => '4'},
        # Make sure sortable version is used
        {:epoch => '10', :version => '3.2', :release => '4'},
        # Make sure sortable release is used
        {:epoch => '10', :version => '3.10', :release => '3.2'},
        # Make sure multiple packages with the same version and different names
        # are handled properly
        {:epoch => '9', :version => '4', :release => '4'},
        {:epoch => '10', :version => '2', :release => '4'},
        {:epoch => '10', :version => '3.2', :release => '4'},
        {:epoch => '10', :version => '3.10', :release => '3.2'},
        {:epoch => '10', :version => '3.10', :release => '3.10'},
      ]
      packages.each do |package|
        package[:version_sortable] = Util::Package.sortable_version(package[:version])
        package[:release_sortable] = Util::Package.sortable_version(package[:release])
      end
      expected_packages = [
        packages[0].with_indifferent_access,
        packages[-1].with_indifferent_access,
      ]
      assert_equal expected_packages, Util::Package.find_latest_packages(packages)
    end

    def test_parse_nvrea
      nvre = "name-1:ver.si.on-relea.se.x86_64.rpm"
      expected = { :epoch => "1",
                   :name => "name",
                   :version => "ver.si.on",
                   :release => "relea.se",
                   :arch => "x86_64",
                   :suffix => "rpm" }
      assert_equal expected, Util::Package.parse_nvrea_nvre(nvre)
      assert_equal expected, Util::Package.parse_nvrea(nvre)
    end

    def test_parse_nvrea_without_rpm
      nvre = "name-1:ver.si.on-relea.se.x86_64"
      expected = { :epoch => "1",
                   :name => "name",
                   :version => "ver.si.on",
                   :release => "relea.se",
                   :arch => "x86_64" }
      assert_equal expected, Util::Package.parse_nvrea_nvre(nvre)
      assert_equal expected, Util::Package.parse_nvrea(nvre)
    end

    def test_parse_nvrea_dots_dashes
      nvre = "name-with-dashes-and.dots-1.0-1.noarch.rpm"
      expected = { :name => "name-with-dashes-and.dots",
                   :version => "1.0",
                   :release => "1",
                   :arch => "noarch",
                   :suffix => "rpm" }
      assert_equal expected, Util::Package.parse_nvrea_nvre(nvre)
      assert_equal expected, Util::Package.parse_nvrea(nvre)
    end

    def test_parse_nvrea_without_epoch
      nvre = "name-ver.si.on-relea.se.x86_64.rpm"
      expected = { :name => "name",
                   :version => "ver.si.on",
                   :release => "relea.se",
                   :arch => "x86_64",
                   :suffix => "rpm" }
      assert_equal expected, Util::Package.parse_nvrea_nvre(nvre)
      assert_equal expected, Util::Package.parse_nvrea(nvre)
    end

    def test_parse_nvrea_without_rpm_epoch
      nvre = "name-ver.si.on-relea.se.x86_64"
      expected = { :name => "name",
                   :version => "ver.si.on",
                   :release => "relea.se",
                   :arch => "x86_64" }
      assert_equal expected, Util::Package.parse_nvrea_nvre(nvre)
      assert_equal expected, Util::Package.parse_nvrea(nvre)
    end

    def test_not_a_nvrea
      nvre = "thisisnotnvrea"
      refute Util::Package.parse_nvrea(nvre)
    end

    def test_parse_nvrea_missing_arch
      #gpg pubkey rpms have a 'nil' arch
      nvre = "gpg-pubkey-d4082792-5b32db75."
      expected = {:name => "gpg-pubkey", :version => "d4082792", :release => "5b32db75"}
      assert_equal expected, Util::Package.parse_nvrea(nvre)
    end

    def test_parse_nvre_full_nvre
      unparsed = "name-1:ver.si.on-relea.se"
      parsed = { :epoch => "1",
                 :name => "name",
                 :version => "ver.si.on",
                 :release => "relea.se" }
      assert_equal parsed, Util::Package.parse_nvre(unparsed)
      assert_equal unparsed, Util::Package.build_nvrea(parsed)
    end

    def test_parse_nvre_without_epoch
      unparsed = "name-ver.si.on-relea.se"
      parsed = { :name => "name",
                 :version => "ver.si.on",
                 :release => "relea.se" }
      assert_equal parsed, Util::Package.parse_nvre(unparsed)
      assert_equal unparsed, Util::Package.build_nvrea(parsed)
    end

    def test_parse_nvre_dots_dashes
      unparsed = "name-with-dashes-and.dots-1.0-1"
      parsed = { :name => "name-with-dashes-and.dots",
                 :version => "1.0",
                 :release => "1" }
      assert_equal parsed, Util::Package.parse_nvre(unparsed)
      assert_equal unparsed, Util::Package.build_nvrea(parsed)
    end

    def test_parse_dependencies
      unparsed = [["package", "EQ", "0", "7.1.4", "14.el7_7", false], ["package", "LT", "2", "7.1.4", "14.el7_7", false], ["package", false]]
      parsed = ["package = 7.1.4-14.el7_7", "package < 2:7.1.4-14.el7_7", "package"]

      assert_equal parsed, Util::Package.parse_dependencies(unparsed)
    end
  end
end
