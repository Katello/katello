require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class DistributorTest < ::ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @mock_smart_proxy = mock('smart_proxy')
          @mock_smart_proxy.stubs(:pulp3_support?).returns(true)
          @mock_smart_proxy.stubs(:pulp2_preferred_for_type?).returns(false)
          @mock_smart_proxy.stubs(:pulp_primary?).returns(true)
          @repo = katello_repositories(:fedora_17_x86_64_duplicate)
          @repo_service = @repo.backend_service(@mock_smart_proxy)
        end

        def distribution_data(bootable)
          images = bootable ? [PulpRpmClient::ImageResponse.new(path: 'images/pxeboot/vmlinuz')] : [PulpRpmClient::ImageResponse.new(path: 'D:\OS2\BOOT\CDFS.IFS')]
          variants = [PulpRpmClient::VariantResponse.new(name: 'MyOS_variant_name')]
          rpm_dist_tree = PulpRpmClient::RpmDistributionTreeResponse.new(pulp_href: "/a/uuid/", release_version: "a version", arch: "h8300", release_name: "MyOS", images: images, variants: variants)
          PulpRpmClient::PaginatedrpmDistributionTreeResponseList.new(results: [rpm_dist_tree])
        end

        def test_import_distribution_data_bootable
          ::Katello::Pulp3::Distribution.stubs(:fetch_content_list).returns(distribution_data(true))
          @repo_service.import_distribution_data
          assert_equal @repo_service.repo.distribution_version, "a version"
          assert_equal @repo_service.repo.distribution_arch, "h8300"
          assert_equal @repo_service.repo.distribution_bootable, true
          assert_equal @repo_service.repo.distribution_family, "MyOS"
          assert_equal @repo_service.repo.distribution_variant, "MyOS_variant_name"
        end

        def test_import_distribution_data_not_bootable
          ::Katello::Pulp3::Distribution.stubs(:fetch_content_list).returns(distribution_data(false))
          @repo_service.import_distribution_data
          assert_equal @repo_service.repo.distribution_version, "a version"
          assert_equal @repo_service.repo.distribution_arch, "h8300"
          assert_equal @repo_service.repo.distribution_bootable, false
          assert_equal @repo_service.repo.distribution_family, "MyOS"
          assert_equal @repo_service.repo.distribution_variant, "MyOS_variant_name"
        end
      end
    end
  end
end
