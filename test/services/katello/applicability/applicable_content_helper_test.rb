require 'katello_test_helper'
module Katello
  module Service
    module Applicability
      class ApplicableContentHelperTest < ActiveSupport::TestCase
        FIXTURES_FILE = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "rpms.yml")

        def trigger_evrs(packages)
          packages.each do |package|
            epoch = package.epoch
            package.update(epoch: "999999999")
            package.update(epoch: epoch)
          end
        end

        def bound_repos(host)
          host.content_facet.bound_repositories.collect do |repo|
            repo.library_instance_id.nil? ? repo.id : repo.library_instance_id
          end
        end

        def setup
          @repo = katello_repositories(:fedora_17_x86_64)
          @host = FactoryBot.build(:host, :with_content, :with_subscription,
                                   :content_view => katello_content_views(:library_dev_view),
                                   :lifecycle_environment => katello_environments(:library))
          @host.save!

          @rpm_one = katello_rpms(:one)
          @rpm_two = katello_rpms(:two)
          @rpm_three = katello_rpms(:three)
          @rpm_one_two = katello_rpms(:one_two)

          @rpm1 = Rpm.where(nvra: "one-1.0-1.el7.x86_64").first
          @rpm2 = Rpm.where(nvra: "one-1.0-2.el7.x86_64").first

          @erratum = Erratum.find_by(errata_id: "RHBA-2014-013")

          @module_stream = ModuleStream.find_by(name: "Ohio")

          HostAvailableModuleStream.create(host_id: @host.id,
                                           available_module_stream_id: AvailableModuleStream.find_by(name: "Ohio").id,
                                           status: "enabled")

          @installed_package1 = InstalledPackage.create(name: @rpm1.name, nvra: @rpm1.nvra, epoch: @rpm1.epoch,
                                                                   version: @rpm1.version, release: @rpm1.release,
                                                                   arch: @rpm1.arch)
          @installed_package2 = InstalledPackage.create(name: @rpm2.name, nvra: @rpm2.nvra, epoch: @rpm2.epoch,
                                                                   version: @rpm2.version, release: @rpm2.release,
                                                                   arch: @rpm2.arch)

          trigger_evrs([@rpm_one, @rpm_two, @rpm_three, @rpm1, @rpm2, @installed_package1, @installed_package2])

          HostInstalledPackage.create(host_id: @host.id, installed_package_id: @installed_package1.id)
          HostInstalledPackage.create(host_id: @host.id, installed_package_id: @installed_package2.id)

          ErratumPackage.create(erratum_id: @erratum.id,
                                nvrea: @rpm2.nvra, name: @rpm2.name, filename: @rpm2.filename)

          Katello::ContentFacetRepository.create(content_facet_id: @host.content_facet.id, repository_id: @repo.id)
          Katello::RepositoryErratum.create(erratum_id: @erratum.id, repository_id: @repo.id)
        end

        def teardown
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).remove(@rpm2.id)
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).remove(@erratum.id)

          @rpm_one.update(modular: false)
          @rpm_one_two.update(modular: false)
          ModuleStreamRpm.delete_all
          HostAvailableModuleStream.delete_all
        end

        def test_rpm_content_ids_returns_something
          package_content_ids = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).fetch_content_ids
          assert_equal [@rpm2.id], package_content_ids
        end

        def test_rpm_content_ids_returns_nothing
          @installed_package1.destroy
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import
          package_content_ids = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).fetch_content_ids
          assert_empty package_content_ids
        end

        def test_erratum_content_ids_returns_something
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import
          erratum_content_ids = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Erratum, bound_repos(@host)).fetch_content_ids
          assert_equal [@erratum.id], erratum_content_ids
        end

        def test_erratum_content_ids_returns_nothing
          erratum_content_ids = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Erratum, bound_repos(@host)).fetch_content_ids
          assert_empty erratum_content_ids
        end

        def test_applicable_differences_adds_rpm_id
          rpm_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).applicable_differences
          assert_equal [[@rpm2.id], []], rpm_differences
        end

        def test_applicable_differences_adds_and_removes_no_rpm_ids
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import
          rpm_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).applicable_differences
          assert_equal [[], []], rpm_differences
        end

        def test_applicable_differences_removes_rpm_id
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import
          @installed_package1.destroy
          rpm_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).applicable_differences
          assert_equal [[], [@rpm2.id]], rpm_differences
        end

        def test_applicable_differences_adds_erratum_id
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import
          erratum_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Erratum, bound_repos(@host)).applicable_differences
          assert_equal [[@erratum.id], []], erratum_differences
        end

        def test_applicable_differences_adds_and_removes_no_errata_ids
          erratum_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Erratum, bound_repos(@host)).applicable_differences
          assert_equal [[], []], erratum_differences
        end

        def test_applicable_differences_remove_erratum_id
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Erratum, bound_repos(@host)).calculate_and_import
          @installed_package1.destroy
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import
          erratum_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Erratum, bound_repos(@host)).applicable_differences
          assert_equal [[], [@erratum.id]], erratum_differences
        end

        def test_applicable_differences_adds_rpm_in_module
          @rpm_one.update(modular: true)
          @rpm_one_two.update(modular: true)

          ModuleStreamRpm.create(module_stream_id: @module_stream.id, rpm_id: @rpm_one.id)
          ModuleStreamRpm.create(module_stream_id: @module_stream.id, rpm_id: @rpm_one_two.id)

          rpm_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).applicable_differences
          assert_equal [[@rpm_one_two.id], []], rpm_differences
        end

        def test_applicable_differences_adds_and_removes_no_module_ids
          module_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::ModuleStream, bound_repos(@host)).applicable_differences
          assert_equal [[], []], module_differences
        end

        def test_applicable_differences_adds_module_id
          @rpm_one.update(modular: true)
          @rpm_one_two.update(modular: true)

          ModuleStreamRpm.create(module_stream_id: @module_stream.id, rpm_id: @rpm_one.id)
          ModuleStreamRpm.create(module_stream_id: @module_stream.id, rpm_id: @rpm_one_two.id)

          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import

          module_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::ModuleStream, bound_repos(@host)).applicable_differences
          assert_equal [[@module_stream.id], []], module_differences
        end

        def test_applicable_differences_removes_module_id
          @rpm_one.update(modular: true)
          @rpm_one_two.update(modular: true)

          ModuleStreamRpm.create(module_stream_id: @module_stream.id, rpm_id: @rpm_one.id)
          ModuleStreamRpm.create(module_stream_id: @module_stream.id, rpm_id: @rpm_one_two.id)

          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import
          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::ModuleStream, bound_repos(@host)).calculate_and_import

          HostAvailableModuleStream.find_by(host_id: @host.id, available_module_stream_id: AvailableModuleStream.
                                            find_by(name: "Ohio").id).update(status: "disabled")

          ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::Rpm, bound_repos(@host)).calculate_and_import

          module_differences = ::Katello::Applicability::ApplicableContentHelper.new(@host.content_facet, ::Katello::ModuleStream, bound_repos(@host)).applicable_differences
          assert_equal [[], [@module_stream.id]], module_differences
        end
      end
    end
  end
end
