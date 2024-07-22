require 'katello_test_helper'

module Katello
  class Util::HostgroupFacetsHelperTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @helper = Katello::Util::HostgroupFacetsHelper.new
      @distro = katello_repositories(:fedora_17_x86_64)
      @dev_distro = katello_repositories(:fedora_17_x86_64_acme_dev)
      @os = ::Redhat.create_operating_system("GreatOS", *@distro.distribution_version.split('.'))
      @cv = @distro.content_view
      @env = @distro.environment
      @arch = architectures(:x86_64)
      @content_source = FactoryBot.create(:smart_proxy,
                                          name: "foobar",
                                          url: "http://example.com/",
                                          lifecycle_environments: [@env, @dev_distro.environment])
      @hostgroup = ::Hostgroup.create(
        name: 'kickstart_repo',
        operatingsystem: @os,
        architecture: @arch
        )
      @facet = Katello::Hostgroup::ContentFacet.create!(hostgroup: @hostgroup)
    end

    def test_interested_hostgroups
      assert_includes @helper.interested_hostgroups, @hostgroup
      @facet.update!(content_source_id: @content_source.id)
      refute_includes @helper.interested_hostgroups, @hostgroup
    end

    def test_interested_hostgroups_parents
      #make sure parents come before children
      @child = ::Hostgroup.create(parent: @hostgroup,
                            name: 'child_repo',
                            operatingsystem: @os,
                            architecture: @arch)
      @child_facet = Katello::Hostgroup::ContentFacet.create!(hostgroup: @child)
      assert_equal([@hostgroup, @child], @helper.interested_hostgroups)
    end

    def test_pick_facet_values_simple
      expected = {
        content_source_id: @content_source.id,
        lifecycle_environment_id: @env.id,
        content_view_id: @cv.id,
        kickstart_repository_id: @distro.id,
      }.with_indifferent_access

      audits = [ mock_audit(expected.slice(:content_source_id, :lifecycle_environment_id)),
                 mock_audit(expected.except(:content_source_id, :lifecycle_environment_id))]
      @hostgroup.expects(:audits).returns(audits)

      actual = @helper.pick_facet_values(@hostgroup)
      assert_equal expected, actual
    end

    def test_pick_facet_values_with_conflicts
      audits = [
        mock_audit(content_source_id: @content_source.id,
                   lifecycle_environment_id: @env.id,
                   content_view_id: @cv.id),
        mock_audit(content_view_id: nil),
      ]
      @hostgroup.expects(:audits).returns(audits)

      #now change content_view_id to nil
      expected = {
        content_source_id: @content_source.id,
        lifecycle_environment_id: @env.id,
        content_view_id: nil,
      }.with_indifferent_access
      assert_equal expected, @helper.pick_facet_values(@hostgroup)
    end

    def mock_audit(changes)
      mock(audited_changes: changes.with_indifferent_access)
    end
  end
end
