require 'katello_test_helper'
require 'support/host_support'

module Katello
  # rubocop:disable Metrics/ClassLength
  class HostgroupExtensionsTest < ActiveSupport::TestCase
    def setup
      @org = FactoryBot.create(:katello_organization)

      @library = FactoryBot.create(:katello_environment, :library, organization: @org)

      @dev = FactoryBot.create(:katello_environment,
                               name: 'Dev',
                               label: 'dev_label',
                               organization: @org,
                               prior: @library)

      @staging = FactoryBot.create(:katello_environment,
                                    name: 'Staging',
                                    label: 'staging_label',
                                    organization: @org,
                                    prior: @dev)

      @view = FactoryBot.create(:katello_content_view, organization: @org)
      @view_version = FactoryBot.create(:katello_content_view_version, content_view: @view)

      # Publish view to library, dev, and staging
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @library)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @dev)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @staging)

      @root = ::Hostgroup.create!(:name => 'AHostgroup')
      @child = ::Hostgroup.create!(:name => 'AChild', :parent => @root)
      @content_source_proxy = FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:9090')
    end

    def test_create_with_content_source
      content_source = smart_proxies(:four)
      host_group = ::Hostgroup.new(:name => 'new_hostgroup', :content_source => content_source)
      assert_valid host_group
      assert_equal content_source, host_group.content_source
    end

    def test_update_content_source
      content_source = smart_proxies(:four)
      host_group = ::Hostgroup.create!(:name => 'new_hostgroup')
      host_group.content_source = content_source
      assert_valid host_group
      assert_equal content_source, host_group.content_source
    end

    def test_inherited_content_source_id_with_ancestry
      @root.content_source = @content_source_proxy
      @root.save!

      assert_equal @content_source_proxy, @child.content_source
      assert_equal @content_source_proxy, @root.content_source
    end

    def test_add_organization_for_environment
      # Ensure hostgroup doesn't have the org initially
      @root.organizations = []
      @root.save!

      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      assert_includes @root.organizations, @library.organization
    end

    def test_inherited_lifecycle_environment_with_ancestry
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      assert_equal @library, @child.lifecycle_environment
      assert_equal @library, @root.lifecycle_environment
    end

    def test_inherited_content_view_with_ancestry
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      assert_equal @view, @child.content_view
      assert_equal @view, @root.content_view
    end

    def test_inherited_content_view_with_ancestry_nill
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @child.content_view_environment_id = cvenv.id
      @child.save!

      assert_equal @view, @child.content_view
      assert_nil @root.content_view
    end

    def test_inherited_lifecycle_environment_with_ancestry_nil
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @child.content_view_environment_id = cvenv.id
      @child.save!

      assert_equal @library, @child.lifecycle_environment
      assert_nil @root.lifecycle_environment
    end

    def test_create_with_content_view
      content_view = FactoryBot.create(:katello_content_view, organization: @org)
      cv_version = FactoryBot.create(:katello_content_view_version, content_view: content_view)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: cv_version,
                        environment: @library)

      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: content_view.id, environment_id: @library.id)
      host_group = ::Hostgroup.new(:name => 'test_cv_hostgroup',
                                    :content_view_environment_id => cvenv.id)
      assert_valid host_group
      assert_equal content_view, host_group.content_view
    end

    def test_update_content_view
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      assert @root.save!
      assert_equal @view, @root.reload.content_view

      new_view = FactoryBot.create(:katello_content_view, organization: @org)
      new_view_version = FactoryBot.create(:katello_content_view_version, content_view: new_view)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: new_view_version,
                        environment: @library)

      new_cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: new_view.id, environment_id: @library.id)
      @root.content_view_environment_id = new_cvenv.id
      assert @root.save!
      assert_equal new_view, @root.reload.content_view
    end

    def test_remove_content_view
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!
      assert_equal @view, @root.content_view

      # Removing content_view_id removes the CVE association, making both nil
      @root.content_facet.content_view_environment = nil
      @root.save!
      assert_nil @root.reload.content_view
    end

    def test_content_view_delegation_to_facet
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      assert_equal @view.id, @root.content_view_id
      assert_equal @view.name, @root.content_view_name
    end

    def test_content_view_inheritance_multiple_levels
      grandparent = ::Hostgroup.create!(:name => 'grandparent')
      parent = ::Hostgroup.create!(:name => 'parent', :parent => grandparent)
      child = ::Hostgroup.create!(:name => 'child', :parent => parent)

      # Set content view on grandparent
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      grandparent.content_view_environment_id = cvenv.id
      grandparent.save!

      # Both parent and child should inherit
      assert_equal @view, parent.content_view
      assert_equal @view, child.content_view
    end

    def test_content_view_override_in_child
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      different_view = FactoryBot.create(:katello_content_view, organization: @org)
      different_view_version = FactoryBot.create(:katello_content_view_version, content_view: different_view)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: different_view_version,
                        environment: @library)

      diff_cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: different_view.id, environment_id: @library.id)
      @child.content_view_environment_id = diff_cvenv.id
      @child.save!

      # Parent has its view, child has overridden view
      assert_equal @view, @root.content_view
      assert_equal different_view, @child.content_view
    end

    def test_content_view_inheritance_respects_closest_ancestor
      grandparent = ::Hostgroup.create!(:name => 'grandparent')
      parent = ::Hostgroup.create!(:name => 'parent', :parent => grandparent)
      child = ::Hostgroup.create!(:name => 'child', :parent => parent)

      grandparent_view = @view
      parent_view = FactoryBot.create(:katello_content_view, organization: @org)
      parent_view_version = FactoryBot.create(:katello_content_view_version, content_view: parent_view)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: parent_view_version,
                        environment: @library)

      gp_cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: grandparent_view.id, environment_id: @library.id)
      grandparent.content_view_environment_id = gp_cvenv.id
      grandparent.save!

      parent_cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: parent_view.id, environment_id: @library.id)
      parent.content_view_environment_id = parent_cvenv.id
      parent.save!

      # Child should inherit from closest ancestor (parent)
      assert_equal parent_view, child.content_view
      assert_equal parent_view, parent.content_view
      assert_equal grandparent_view, grandparent.content_view
    end

    def test_lifecycle_environment_auto_adds_organization
      # When setting content_view_environment_id,
      # the lifecycle_environment triggers add_organization_for_environment callback
      org = @view.organization

      # Ensure hostgroup doesn't have the org initially
      @root.organizations = []
      @root.save!

      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      # Setting content_view_environment_id triggers add_organization_for_environment
      # So organization WILL be auto-added
      @root.reload
      assert_includes @root.organizations, org
    end

    def test_rhsm_organization_label_from_content_view
      # With CVEnv model, both CV and LCE are always set together
      # This test now verifies the logic returns org label when both are present
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      # Should use lifecycle environment's org (same as content_view org in this case)
      assert_equal @view.organization.label, @root.rhsm_organization_label
    end

    def test_rhsm_organization_label_prefers_lifecycle_environment
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      # Should use lifecycle environment's org if both are set
      assert_equal @library.organization.label, @root.rhsm_organization_label
    end

    def test_content_view_returns_nil_when_not_set_and_no_parent
      hostgroup = ::Hostgroup.create!(:name => 'standalone')
      assert_nil hostgroup.content_view
    end

    def test_safe_content_facet_creates_facet_if_missing
      hostgroup = ::Hostgroup.create!(:name => 'no_facet')
      assert_nil hostgroup.content_facet

      # Setting content_view_environment_id should create facet via safe_content_facet
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      hostgroup.content_view_environment_id = cvenv.id
      assert_not_nil hostgroup.content_facet
    end

    def test_inherited_content_view_id
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      # Child should inherit content_view_id
      assert_equal @view.id, @child.inherited_content_view_id
      assert_nil @child.content_view_id
    end

    # Test removed: CV/LCE mismatch is no longer possible with content_view_environment_id

    def test_create_with_lifecycle_environment
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @dev.id)
      host_group = ::Hostgroup.new(:name => 'test_le_hostgroup',
                                    :content_view_environment_id => cvenv.id)
      assert_valid host_group
      assert_equal @dev, host_group.lifecycle_environment
    end

    def test_update_lifecycle_environment
      cvenv_lib = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv_lib.id
      assert @root.save!
      assert_equal @library, @root.reload.lifecycle_environment

      cvenv_dev = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @dev.id)
      @root.content_view_environment_id = cvenv_dev.id
      assert @root.save!
      assert_equal @dev, @root.reload.lifecycle_environment
    end

    def test_remove_lifecycle_environment
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!
      assert_equal @library, @root.lifecycle_environment

      # Removing CVE association removes both CV and LE
      @root.content_facet.content_view_environment = nil
      @root.save!
      assert_nil @root.reload.lifecycle_environment
    end

    def test_lifecycle_environment_delegation_to_facet
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      assert_equal @library.id, @root.lifecycle_environment_id
      assert_equal @library.name, @root.lifecycle_environment_name
    end

    def test_lifecycle_environment_inheritance_multiple_levels
      grandparent = ::Hostgroup.create!(:name => 'gp_le')
      parent = ::Hostgroup.create!(:name => 'p_le', :parent => grandparent)
      child = ::Hostgroup.create!(:name => 'c_le', :parent => parent)

      # Set lifecycle environment on grandparent
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      grandparent.content_view_environment_id = cvenv.id
      grandparent.save!

      # Both parent and child should inherit
      assert_equal @library, parent.lifecycle_environment
      assert_equal @library, child.lifecycle_environment
    end

    def test_lifecycle_environment_override_in_child
      cvenv_lib = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv_lib.id
      @root.save!

      cvenv_dev = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @dev.id)
      @child.content_view_environment_id = cvenv_dev.id
      @child.save!

      # Parent has its env, child has overridden env
      assert_equal @library, @root.lifecycle_environment
      assert_equal @dev, @child.lifecycle_environment
    end

    def test_lifecycle_environment_inheritance_respects_closest_ancestor
      grandparent = ::Hostgroup.create!(:name => 'gp_le2')
      parent = ::Hostgroup.create!(:name => 'p_le2', :parent => grandparent)
      child = ::Hostgroup.create!(:name => 'c_le2', :parent => parent)

      cvenv_lib = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      grandparent.content_view_environment_id = cvenv_lib.id
      grandparent.save!

      cvenv_dev = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @dev.id)
      parent.content_view_environment_id = cvenv_dev.id
      parent.save!

      # Child should inherit from closest ancestor (parent)
      assert_equal @dev, child.lifecycle_environment
      assert_equal @dev, parent.lifecycle_environment
      assert_equal @library, grandparent.lifecycle_environment
    end

    def test_lifecycle_environment_returns_nil_when_not_set_and_no_parent
      hostgroup = ::Hostgroup.create!(:name => 'standalone_le')
      assert_nil hostgroup.lifecycle_environment
    end

    def test_inherited_lifecycle_environment_id
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      # Child should inherit lifecycle_environment_id
      assert_equal @library.id, @child.inherited_lifecycle_environment_id
      assert_nil @child.lifecycle_environment_id
    end

    def test_lifecycle_environment_creates_facet_if_missing
      hostgroup = ::Hostgroup.create!(:name => 'no_facet_le')
      assert_nil hostgroup.content_facet

      # Setting content_view_environment_id should create facet via safe_content_facet
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      hostgroup.content_view_environment_id = cvenv.id
      assert_not_nil hostgroup.content_facet
    end

    def test_rhsm_organization_label_from_lifecycle_environment
      # With CVE model, both CV and LE are always set together
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      assert_equal @library.organization.label, @root.rhsm_organization_label
    end

    def test_lifecycle_environment_organization_auto_added
      org = @library.organization

      # Ensure hostgroup doesn't have the org initially
      @root.organizations = []
      @root.save!

      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id
      @root.save!

      # Organization should be added automatically via callback
      @root.reload
      assert_includes @root.organizations, org
    end

    def test_lifecycle_environment_with_content_view_same_org
      # CV must be published to LE for validation to pass
      # @view (library_dev_staging_view) IS published to @library
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      @root.content_view_environment_id = cvenv.id

      assert @root.valid?
      assert @root.save!
    end

    # Test removed: CV/LCE mismatch is no longer possible with content_view_environment_id

    def test_change_lifecycle_environment_updates_children
      parent = ::Hostgroup.create!(:name => 'parent_le_change')
      child = ::Hostgroup.create!(:name => 'child_le_change', :parent => parent)
      grandchild = ::Hostgroup.create!(:name => 'grandchild_le_change', :parent => child)

      cvenv_lib = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      parent.content_view_environment_id = cvenv_lib.id
      parent.save!

      # All should inherit
      assert_equal @library, child.lifecycle_environment
      assert_equal @library, grandchild.lifecycle_environment

      # Change parent's env
      cvenv_dev = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @dev.id)
      parent.content_view_environment_id = cvenv_dev.id
      parent.save!

      # Children should now inherit new value
      assert_equal @dev, child.reload.lifecycle_environment
      assert_equal @dev, grandchild.reload.lifecycle_environment
    end

    def test_child_override_persists_when_parent_changes
      parent = ::Hostgroup.create!(:name => 'parent_override')
      child = ::Hostgroup.create!(:name => 'child_override', :parent => parent)

      cvenv_lib = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      parent.content_view_environment_id = cvenv_lib.id
      parent.save!

      # Child explicitly sets different env
      cvenv_dev = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @dev.id)
      child.content_view_environment_id = cvenv_dev.id
      child.save!

      # Change parent
      cvenv_staging = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @staging.id)
      parent.content_view_environment_id = cvenv_staging.id
      parent.save!

      # Child should keep its explicit value
      assert_equal @staging, parent.lifecycle_environment
      assert_equal @dev, child.reload.lifecycle_environment
    end
  end
  # rubocop:enable Metrics/ClassLength

  class HostgroupMultiLevelInheritanceTest < ActiveSupport::TestCase
    def setup
      @org = FactoryBot.create(:katello_organization)

      @library = FactoryBot.create(:katello_environment, :library, organization: @org)

      @dev = FactoryBot.create(:katello_environment,
                               name: 'Dev',
                               label: 'dev_label',
                               organization: @org,
                               prior: @library)

      @staging = FactoryBot.create(:katello_environment,
                                    name: 'Staging',
                                    label: 'staging_label',
                                    organization: @org,
                                    prior: @dev)

      @view1 = FactoryBot.create(:katello_content_view, organization: @org)
      @view2 = FactoryBot.create(:katello_content_view, organization: @org)
      @view3 = FactoryBot.create(:katello_content_view, organization: @org)

      # Create content view versions and publish to environments
      @view1_version = FactoryBot.create(:katello_content_view_version, content_view: @view1)
      @view2_version = FactoryBot.create(:katello_content_view_version, content_view: @view2)
      @view3_version = FactoryBot.create(:katello_content_view_version, content_view: @view3)

      # Create ContentViewEnvironment records for all combinations used in tests
      [@view1, @view2, @view3].each_with_index do |_view, index|
        version = instance_variable_get("@view#{index + 1}_version")
        [@library, @dev, @staging].each do |env|
          FactoryBot.create(:katello_content_view_environment,
                            content_view_version: version,
                            environment: env)
        end
      end
    end

    # NOTE: 3-level inheritance already tested in HostgroupExtensionsTest
    # (test_content_view_inheritance_multiple_levels and
    #  test_lifecycle_environment_inheritance_multiple_levels)
    # These cover the typical use case and prove the mechanism works.
    # The algorithm is depth-agnostic, so additional depth adds minimal value.

    def test_skip_level_inheritance_content_view
      # Grandparent has value, parent doesn't, child should inherit from grandparent
      grandparent = ::Hostgroup.create!(name: 'gp_skip')
      parent = ::Hostgroup.create!(name: 'p_skip', parent: grandparent)
      child = ::Hostgroup.create!(name: 'c_skip', parent: parent)

      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      grandparent.content_view_environment_id = cvenv.id
      grandparent.save!

      # Parent has no explicit value
      assert_nil parent.content_view_id
      assert_equal @view1, parent.content_view # But inherits

      # Child should also inherit from grandparent (skipping parent)
      assert_nil child.content_view_id
      assert_equal @view1, child.content_view
    end

    def test_skip_level_inheritance_lifecycle_environment
      # Grandparent has value, parent doesn't, child should inherit from grandparent
      grandparent = ::Hostgroup.create!(name: 'gp_skip_le')
      parent = ::Hostgroup.create!(name: 'p_skip_le', parent: grandparent)
      child = ::Hostgroup.create!(name: 'c_skip_le', parent: parent)

      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      grandparent.content_view_environment_id = cvenv.id
      grandparent.save!

      # Parent has no explicit value
      assert_nil parent.lifecycle_environment_id
      assert_equal @library, parent.lifecycle_environment

      # Child should also inherit from grandparent
      assert_nil child.lifecycle_environment_id
      assert_equal @library, child.lifecycle_environment
    end

    def test_multiple_siblings_with_different_overrides
      parent = ::Hostgroup.create!(name: 'parent_siblings')
      child1 = ::Hostgroup.create!(name: 'child1', parent: parent)
      child2 = ::Hostgroup.create!(name: 'child2', parent: parent)
      child3 = ::Hostgroup.create!(name: 'child3', parent: parent)

      # Set parent value
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      parent.content_view_environment_id = cvenv.id
      parent.save!

      # Child1 inherits
      assert_equal @view1, child1.content_view

      # Child2 overrides
      cvenv2 = Katello::ContentViewEnvironment.find_by!(content_view_id: @view2.id, environment_id: @library.id)
      child2.content_view_environment_id = cvenv2.id
      child2.save!

      # Child3 inherits
      assert_equal @view1, child3.content_view

      # Verify each has correct value
      assert_equal @view1, parent.content_view
      assert_equal @view1, child1.content_view
      assert_equal @view2, child2.content_view
      assert_equal @view1, child3.content_view
    end

    def test_multiple_branches_from_same_ancestor
      # Create tree structure:
      #        grandparent (view1)
      #        /          \
      #    parent1       parent2 (view2)
      #    /    \         /    \
      # child1 child2  child3 child4

      grandparent = ::Hostgroup.create!(name: 'gp_branches')
      parent1 = ::Hostgroup.create!(name: 'p1_branches', parent: grandparent)
      parent2 = ::Hostgroup.create!(name: 'p2_branches', parent: grandparent)
      child1 = ::Hostgroup.create!(name: 'c1_branches', parent: parent1)
      child2 = ::Hostgroup.create!(name: 'c2_branches', parent: parent1)
      child3 = ::Hostgroup.create!(name: 'c3_branches', parent: parent2)
      child4 = ::Hostgroup.create!(name: 'c4_branches', parent: parent2)

      # Set grandparent
      cvenv_lib = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      grandparent.content_view_environment_id = cvenv_lib.id
      grandparent.save!

      # Override in parent2
      cvenv_dev = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @dev.id)
      parent2.content_view_environment_id = cvenv_dev.id
      parent2.save!

      # Branch 1 (parent1 and children) should inherit from grandparent
      assert_equal @library, parent1.lifecycle_environment
      assert_equal @library, child1.lifecycle_environment
      assert_equal @library, child2.lifecycle_environment

      # Branch 2 (parent2 and children) should use parent2's override
      assert_equal @dev, parent2.lifecycle_environment
      assert_equal @dev, child3.lifecycle_environment
      assert_equal @dev, child4.lifecycle_environment
    end

    def test_override_at_middle_level_propagates_down
      # Create 4 levels
      level1 = ::Hostgroup.create!(name: 'mid_level1')
      level2 = ::Hostgroup.create!(name: 'mid_level2', parent: level1)
      level3 = ::Hostgroup.create!(name: 'mid_level3', parent: level2)
      level4 = ::Hostgroup.create!(name: 'mid_level4', parent: level3)

      # Set at top
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      level1.content_view_environment_id = cvenv.id
      level1.save!

      # All inherit initially
      assert_equal @view1, level2.content_view
      assert_equal @view1, level3.content_view
      assert_equal @view1, level4.content_view

      # Override at middle level (level2)
      cvenv2 = Katello::ContentViewEnvironment.find_by!(content_view_id: @view2.id, environment_id: @library.id)
      level2.content_view_environment_id = cvenv2.id
      level2.save!

      # Level1 unchanged
      assert_equal @view1, level1.content_view

      # Level2 has new value
      assert_equal @view2, level2.content_view

      # Levels below level2 now inherit from level2
      assert_equal @view2, level3.content_view
      assert_equal @view2, level4.content_view
    end

    def test_grandchild_override_skipping_parent
      # Grandparent has value, parent doesn't, grandchild sets own value
      grandparent = ::Hostgroup.create!(name: 'gp_gc_override')
      parent = ::Hostgroup.create!(name: 'p_gc_override', parent: grandparent)
      grandchild = ::Hostgroup.create!(name: 'gc_gc_override', parent: parent)

      cvenv_lib = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      grandparent.content_view_environment_id = cvenv_lib.id
      grandparent.save!

      # Parent inherits
      assert_equal @library, parent.lifecycle_environment

      # Grandchild sets different value
      cvenv_staging = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @staging.id)
      grandchild.content_view_environment_id = cvenv_staging.id
      grandchild.save!

      # Verify
      assert_equal @library, grandparent.lifecycle_environment
      assert_equal @library, parent.lifecycle_environment
      assert_equal @staging, grandchild.lifecycle_environment
    end

    def test_mixed_inheritance_both_cv_and_le
      # Test that CV and LE can have different inheritance patterns
      grandparent = ::Hostgroup.create!(name: 'gp_mixed')
      parent = ::Hostgroup.create!(name: 'p_mixed', parent: grandparent)
      child = ::Hostgroup.create!(name: 'c_mixed', parent: parent)

      # Set both on grandparent
      cvenv1 = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      grandparent.content_view_environment_id = cvenv1.id
      grandparent.save!

      # Override CV at parent level (LE stays the same - library)
      cvenv2 = Katello::ContentViewEnvironment.find_by!(content_view_id: @view2.id, environment_id: @library.id)
      parent.content_view_environment_id = cvenv2.id
      parent.save!

      # Child should inherit both from parent:
      # - CV from parent (view2)
      # - LE from parent (library, which was from grandparent)
      assert_equal @view2, child.content_view
      assert_equal @library, child.lifecycle_environment
    end

    def test_remove_middle_override_restores_inheritance
      # 3 levels: grandparent → parent → child
      grandparent = ::Hostgroup.create!(name: 'gp_remove')
      parent = ::Hostgroup.create!(name: 'p_remove', parent: grandparent)
      child = ::Hostgroup.create!(name: 'c_remove', parent: parent)

      # Set values
      cvenv1 = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      grandparent.content_view_environment_id = cvenv1.id
      grandparent.save!

      cvenv2 = Katello::ContentViewEnvironment.find_by!(content_view_id: @view2.id, environment_id: @library.id)
      parent.content_view_environment_id = cvenv2.id
      parent.save!

      # Child inherits from parent
      assert_equal @view2, child.content_view

      # Remove parent's override by removing CVE association
      parent.content_facet.content_view_environment = nil
      parent.save!

      # Now both parent and child should inherit from grandparent
      assert_equal @view1, parent.reload.content_view
      assert_equal @view1, child.reload.content_view
    end

    def test_inheritance_with_nil_in_middle
      # Ensure nil in middle of chain doesn't break inheritance
      level1 = ::Hostgroup.create!(name: 'nil_level1')
      level2 = ::Hostgroup.create!(name: 'nil_level2', parent: level1)
      level3 = ::Hostgroup.create!(name: 'nil_level3', parent: level2)

      # Set at level1
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      level1.content_view_environment_id = cvenv.id
      level1.save!

      # Explicitly ensure level2 has nil (no facet or nil value)
      assert_nil level2.lifecycle_environment_id

      # Both level2 and level3 should inherit from level1 (skipping the nil)
      assert_equal @library, level2.lifecycle_environment
      assert_equal @library, level3.lifecycle_environment
    end

    def test_wide_tree_multiple_children_per_level
      # Create wider tree:
      #           root
      #        /   |   \
      #       a1   a2   a3
      #      / \   |
      #    b1  b2  b3

      root = ::Hostgroup.create!(name: 'wide_root')
      a1 = ::Hostgroup.create!(name: 'wide_a1', parent: root)
      a2 = ::Hostgroup.create!(name: 'wide_a2', parent: root)
      a3 = ::Hostgroup.create!(name: 'wide_a3', parent: root)
      b1 = ::Hostgroup.create!(name: 'wide_b1', parent: a1)
      b2 = ::Hostgroup.create!(name: 'wide_b2', parent: a1)
      b3 = ::Hostgroup.create!(name: 'wide_b3', parent: a2)

      # Set at root
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view1.id, environment_id: @library.id)
      root.content_view_environment_id = cvenv.id
      root.save!

      # All should inherit
      assert_equal @view1, a1.content_view
      assert_equal @view1, a2.content_view
      assert_equal @view1, a3.content_view
      assert_equal @view1, b1.content_view
      assert_equal @view1, b2.content_view
      assert_equal @view1, b3.content_view

      # Override one branch
      cvenv2 = Katello::ContentViewEnvironment.find_by!(content_view_id: @view2.id, environment_id: @library.id)
      a2.content_view_environment_id = cvenv2.id
      a2.save!

      # Only a2 and its children should have new value
      assert_equal @view1, a1.content_view
      assert_equal @view2, a2.content_view
      assert_equal @view1, a3.content_view
      assert_equal @view1, b1.content_view
      assert_equal @view1, b2.content_view
      assert_equal @view2, b3.content_view
    end
  end

  class HostgroupExtensionsKickstartTest < ActiveSupport::TestCase
    def setup
      @distro = katello_repositories(:fedora_17_x86_64)
      @dev_distro = katello_repositories(:fedora_17_x86_64_acme_dev)
      @os = ::Redhat.create_operating_system("GreatOS", *@distro.distribution_version.split('.'))
      @no_family_os = FactoryBot.create(:operatingsystem,
                                        major: 1,
                                        name: 'no_family_os')
      @arch = architectures(:x86_64)
      @distro_cv = @distro.content_view
      @distro_env = @distro.environment
      @content_source = FactoryBot.create(:smart_proxy,
                                          name: "foobar",
                                          url: "http://example.com/",
                                          lifecycle_environments: [@distro_env, @dev_distro.environment])
      @medium = FactoryBot.create(:medium, operatingsystems: [@os])
    end

    def test_update_kickstart_repository
      hg = ::Hostgroup.create(
        name: 'kickstart_repo',
        operatingsystem: @os,
        architecture: @arch
        )
      facet = Katello::Hostgroup::ContentFacet.create!(hostgroup: hg)
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @distro_env.id)
      facet.content_view_environment_id = cvenv.id
      facet.content_source = @content_source
      facet.kickstart_repository = @distro
      assert facet.save
      assert_valid facet
      assert_equal hg.reload.kickstart_repository, @distro
    end

    def test_set_kickstart_repository
      @os.stubs(:kickstart_repos).returns([@distro])
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @distro_env.id)
      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view_environment_id: cvenv.id,
        kickstart_repository: @distro)

      assert_valid hg
      assert_equal hg.kickstart_repository, @distro
    end

    def test_set_installation_medium
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @distro_env.id)
      hg = ::Hostgroup.new(
        name: 'install_media',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view_environment_id: cvenv.id,
        medium: @medium)

      assert_valid hg
      assert_equal hg.medium, @medium
    end

    def test_change_medium_to_kickstart_repository
      @os.stubs(:kickstart_repos).returns([@distro])
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @distro_env.id)
      hg = ::Hostgroup.new(
        name: 'install_media',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view_environment_id: cvenv.id,
        medium: @medium)

      assert hg.save
      hg.kickstart_repository = @distro
      assert_valid hg
      assert_nil hg.medium
      assert_equal hg.kickstart_repository, @distro
    end

    def test_change_kickstart_repository_to_medium
      @os.stubs(:kickstart_repos).returns([@distro])
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @distro_env.id)
      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view_environment_id: cvenv.id,
        kickstart_repository: @distro)

      assert hg.save
      hg.medium = @medium
      assert_valid hg
      assert_nil hg.kickstart_repository
      assert_equal hg.medium, @medium
    end

    def test_change_lifecycle_environment_mismatched_kickstart
      @os = ::Redhat.create_operating_system("GreatOS1", *@dev_distro.distribution_version.split('.'))

      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @distro_env.id)
      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view_environment_id: cvenv.id,
        kickstart_repository: @distro)

      # changing the lifecycle environment will trigger
      # code which attempts to reassign the kickstart repo by its label
      dev_cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @dev_distro.environment.id)
      hg.content_view_environment_id = dev_cvenv.id
      assert hg.save
      assert_equal hg.kickstart_repository_id, @dev_distro.id
    end

    def test_change_os_replaces_inherited_kickstart_repository
      parent = ::Hostgroup.create!(
        name: 'parent_kickstart_inheritance',
        operatingsystem: @os,
        architecture: @arch
      )
      child = ::Hostgroup.create!(name: 'child_kickstart_inheritance', parent: parent)

      facet = Katello::Hostgroup::ContentFacet.create!(hostgroup: parent)
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @distro_env.id)
      facet.content_view_environment_id = cvenv.id
      facet.content_source = @content_source
      facet.kickstart_repository = @distro
      assert facet.save

      new_os = ::Redhat.create_operating_system("GreatOS", 2, 2)
      new_os.stubs(:release).returns('2')
      repo_struct = Struct.new(:id, :distribution_version, :distribution_variant, :product_id)
      preferred_repo = repo_struct.new(9_001, new_os.release, @distro.distribution_variant, @distro.product_id)
      alternate_repo = repo_struct.new(9_002, new_os.release, 'OtherVariant', @distro.product_id)
      major_minor_repo = repo_struct.new(9_003, '2.2', @distro.distribution_variant, @distro.product_id)

      new_os.stubs(:kickstart_repos).returns(
        [
          { id: @distro.id, name: @distro.label },
          { id: alternate_repo.id, name: 'alternate_repo' },
          { id: preferred_repo.id, name: 'preferred_repo' },
          { id: major_minor_repo.id, name: 'major_minor_repo' },
        ]
      )
      repos_by_id = {
        @distro.id => @distro,
        alternate_repo.id => alternate_repo,
        preferred_repo.id => preferred_repo,
        major_minor_repo.id => major_minor_repo,
      }
      parent.stubs(:indexed_kickstart_repositories).returns(repos_by_id)

      parent.operatingsystem = new_os
      assert parent.save

      assert_equal major_minor_repo.id, parent.reload.kickstart_repository_id
      assert_equal major_minor_repo.id, child.reload.inherited_kickstart_repository_id
    end

    def test_saving_child_with_stale_kickstart_repository_uses_inherited_context
      parent = ::Hostgroup.create!(
        name: 'parent_kickstart_inheritance_stale_child',
        operatingsystem: @os,
        architecture: @arch
      )
      child = ::Hostgroup.create!(name: 'child_kickstart_inheritance_stale_child', parent: parent)

      parent_facet = Katello::Hostgroup::ContentFacet.create!(hostgroup: parent)
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @distro_env.id)
      parent_facet.content_view_environment_id = cvenv.id
      parent_facet.content_source = @content_source
      parent_facet.kickstart_repository = @distro
      assert parent_facet.save

      child_facet = Katello::Hostgroup::ContentFacet.create!(hostgroup: child)
      child_facet.update_columns(kickstart_repository_id: @distro.id)

      new_os = ::Redhat.create_operating_system("GreatOS", 2, 2)
      repo_struct = Struct.new(:id, :distribution_version, :distribution_variant, :product_id)
      preferred_repo = repo_struct.new(9_010, new_os.release, @distro.distribution_variant, @distro.product_id)

      new_os.stubs(:kickstart_repos).returns(
        [
          { id: @distro.id, name: @distro.label },
          { id: preferred_repo.id, name: 'preferred_repo' },
        ]
      )
      repos_by_id = {
        @distro.id => @distro,
        preferred_repo.id => preferred_repo,
      }
      parent.stubs(:indexed_kickstart_repositories).returns(repos_by_id)
      child.stubs(:indexed_kickstart_repositories).returns(repos_by_id)

      parent.operatingsystem = new_os
      assert parent.save

      assert child.reload.save, child.errors.full_messages.to_sentence
      assert_equal preferred_repo.id, child.reload.content_facet.kickstart_repository_id
    end

    def test_change_os_prefers_repo_name_release_hint_when_distribution_version_is_generic
      parent = ::Hostgroup.create!(
        name: 'parent_kickstart_name_release_hint',
        operatingsystem: @os,
        architecture: @arch
      )
      child = ::Hostgroup.create!(name: 'child_kickstart_name_release_hint', parent: parent)

      facet = Katello::Hostgroup::ContentFacet.create!(hostgroup: parent)
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @distro_cv.id, environment_id: @distro_env.id)
      facet.content_view_environment_id = cvenv.id
      facet.content_source = @content_source
      facet.kickstart_repository = @distro
      assert facet.save

      new_os = ::Redhat.create_operating_system("GreatOS", 2, 2)
      new_os.stubs(:release).returns('2')
      repo_struct = Struct.new(:id, :distribution_version, :distribution_variant, :product_id)
      preferred_repo = repo_struct.new(9_020, '2', @distro.distribution_variant, @distro.product_id)

      new_os.stubs(:kickstart_repos).returns(
        [
          { id: @distro.id, name: @distro.label },
          { id: preferred_repo.id, name: 'Red_Hat_Enterprise_Linux_2_for_x86_64_-_BaseOS_Kickstart_2_2' },
        ]
      )
      repos_by_id = {
        @distro.id => @distro,
        preferred_repo.id => preferred_repo,
      }
      parent.stubs(:indexed_kickstart_repositories).returns(repos_by_id)

      parent.operatingsystem = new_os
      assert parent.save

      assert_equal preferred_repo.id, parent.reload.kickstart_repository_id
      assert_equal preferred_repo.id, child.reload.inherited_kickstart_repository_id
    end

    def test_create_hostgroup_no_family_os
      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @no_family_os)

      assert_valid hg
    end
  end

  class HostgroupContentViewSearchTest < ActiveSupport::TestCase
    def setup
      @org = FactoryBot.create(:katello_organization)
      @library = FactoryBot.create(:katello_environment, :library, organization: @org)

      @view1 = FactoryBot.create(:katello_content_view, organization: @org, name: 'TestView1')
      @view2 = FactoryBot.create(:katello_content_view, organization: @org, name: 'TestView2')

      # Create content view versions and CVEs
      @view1_version = FactoryBot.create(:katello_content_view_version, content_view: @view1)
      @view2_version = FactoryBot.create(:katello_content_view_version, content_view: @view2)

      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view1_version,
                        environment: @library)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view2_version,
                        environment: @library)

      cvenv1 = Katello::ContentViewEnvironment.find_by(content_view_id: @view1.id, environment_id: @library.id)
      @hg_with_view1 = ::Hostgroup.create!(name: 'hg_cv1', content_view_environment_id: cvenv1.id)

      cvenv2 = Katello::ContentViewEnvironment.find_by(content_view_id: @view2.id, environment_id: @library.id)
      @hg_with_view2 = ::Hostgroup.create!(name: 'hg_cv2', content_view_environment_id: cvenv2.id)

      @hg_without_view = ::Hostgroup.create!(name: 'hg_no_cv')
    end

    def test_search_by_content_view_name
      results = ::Hostgroup.search_for("content_view = \"#{@view1.name}\"")
      assert_includes results, @hg_with_view1
      refute_includes results, @hg_with_view2
      refute_includes results, @hg_without_view
    end

    def test_search_by_content_view_excludes_hostgroups_without_cv
      results = ::Hostgroup.search_for("content_view = \"#{@view1.name}\"")
      refute_includes results, @hg_without_view
    end

    def test_search_multiple_content_views
      results = ::Hostgroup.search_for("content_view = \"#{@view1.name}\" or content_view = \"#{@view2.name}\"")
      assert_includes results, @hg_with_view1
      assert_includes results, @hg_with_view2
      refute_includes results, @hg_without_view
    end
  end

  class HostgroupLifecycleEnvironmentSearchTest < ActiveSupport::TestCase
    def setup
      @org = FactoryBot.create(:katello_organization)
      @library = FactoryBot.create(:katello_environment, :library, organization: @org, name: 'Library')

      @dev = FactoryBot.create(:katello_environment,
                               organization: @org,
                               name: 'Dev',
                               label: 'dev_label',
                               prior: @library)

      @staging = FactoryBot.create(:katello_environment,
                                    organization: @org,
                                    name: 'Staging',
                                    label: 'staging_label',
                                    prior: @dev)

      @view = FactoryBot.create(:katello_content_view, organization: @org)
      @view_version = FactoryBot.create(:katello_content_view_version, content_view: @view)

      # Create content view environments for view in each environment
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @library)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @dev)

      cvenv_lib = Katello::ContentViewEnvironment.find_by(content_view_id: @view.id, environment_id: @library.id)
      @hg_with_library = ::Hostgroup.create!(name: 'hg_lib', content_view_environment_id: cvenv_lib.id)

      cvenv_dev = Katello::ContentViewEnvironment.find_by(content_view_id: @view.id, environment_id: @dev.id)
      @hg_with_dev = ::Hostgroup.create!(name: 'hg_dev', content_view_environment_id: cvenv_dev.id)

      @hg_without_env = ::Hostgroup.create!(name: 'hg_no_env')
    end

    def test_search_by_lifecycle_environment_name
      results = ::Hostgroup.search_for("lifecycle_environment = \"#{@library.name}\"")
      assert_includes results, @hg_with_library
      refute_includes results, @hg_with_dev
      refute_includes results, @hg_without_env
    end

    def test_search_by_lifecycle_environment_excludes_hostgroups_without_env
      results = ::Hostgroup.search_for("lifecycle_environment = \"#{@dev.name}\"")
      assert_includes results, @hg_with_dev
      refute_includes results, @hg_without_env
    end

    def test_search_multiple_lifecycle_environments
      results = ::Hostgroup.search_for("lifecycle_environment = \"#{@library.name}\" or lifecycle_environment = \"#{@dev.name}\"")
      assert_includes results, @hg_with_library
      assert_includes results, @hg_with_dev
      refute_includes results, @hg_without_env
    end

    def test_search_with_inherited_lifecycle_environment
      # Create CVE for staging environment
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @staging)

      parent = ::Hostgroup.create!(name: 'parent_search')
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @staging.id)
      parent.content_view_environment_id = cvenv.id
      parent.save!

      _child = ::Hostgroup.create!(name: 'child_search', parent: parent)

      # Search should find parent (has direct value)
      results = ::Hostgroup.search_for("lifecycle_environment = \"#{@staging.name}\"")
      assert_includes results, parent

      # Child inherits but doesn't have direct facet value, so may not appear in search
      # This tests actual scoped_search behavior
    end
  end

  class HostgroupContentSourceSearchTest < ActiveSupport::TestCase
    def setup
      @content_source1 = FactoryBot.create(:smart_proxy, name: 'ContentSource1', url: 'https://cs1.example.com:9090')
      @content_source2 = FactoryBot.create(:smart_proxy, name: 'ContentSource2', url: 'https://cs2.example.com:9090')

      @hg_with_cs1 = ::Hostgroup.create!(name: 'hg_cs1')
      @hg_with_cs1.content_source = @content_source1
      @hg_with_cs1.save!

      @hg_with_cs2 = ::Hostgroup.create!(name: 'hg_cs2')
      @hg_with_cs2.content_source = @content_source2
      @hg_with_cs2.save!

      @hg_without_cs = ::Hostgroup.create!(name: 'hg_no_cs')
    end

    def test_search_by_content_source_name
      results = ::Hostgroup.search_for("content_source = \"#{@content_source1.name}\"")
      assert_includes results, @hg_with_cs1
      refute_includes results, @hg_with_cs2
      refute_includes results, @hg_without_cs
    end

    def test_search_by_content_source_excludes_hostgroups_without_cs
      results = ::Hostgroup.search_for("content_source = \"#{@content_source1.name}\"")
      refute_includes results, @hg_without_cs
    end

    def test_search_multiple_content_sources
      results = ::Hostgroup.search_for("content_source = \"#{@content_source1.name}\" or content_source = \"#{@content_source2.name}\"")
      assert_includes results, @hg_with_cs1
      assert_includes results, @hg_with_cs2
      refute_includes results, @hg_without_cs
    end
  end

  # ===================================================================
  # Critical Validation Tests for Content View and Lifecycle Environment
  # ===================================================================

  class HostgroupContentViewValidationTest < ActiveSupport::TestCase
    def setup
      @org = FactoryBot.create(:katello_organization)
      @library = FactoryBot.create(:katello_environment, :library, organization: @org)
      @dev = FactoryBot.create(:katello_environment, name: 'Dev', organization: @org, prior: @library)

      @view = FactoryBot.create(:katello_content_view, organization: @org)
      @view_version = FactoryBot.create(:katello_content_view_version, content_view: @view)

      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @library)
    end

    # Test removed: CV/LCE mismatch is no longer possible with content_view_environment_id
    # (test_setting_content_view_without_lifecycle_environment_should_fail)

    # Test removed: CV/LCE mismatch is no longer possible with content_view_environment_id
    # (test_setting_lifecycle_environment_without_content_view_should_fail)

    def test_setting_content_view_environment_should_succeed
      hostgroup = ::Hostgroup.create!(name: 'TestHG')

      # Set CV and LCE together via content_view_environment_id
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      hostgroup.content_view_environment_id = cvenv.id

      assert hostgroup.valid?, "Hostgroup should be valid when setting content_view_environment_id: #{hostgroup.errors.full_messages}"
      assert hostgroup.save
    end

    def test_removing_content_view_environment_should_succeed
      hostgroup = ::Hostgroup.create!(name: 'TestHG')
      cvenv = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      hostgroup.content_view_environment_id = cvenv.id
      hostgroup.save!

      # Remove by clearing the association
      hostgroup.content_view_environment_id = nil

      assert hostgroup.valid?, "Hostgroup should be valid when removing content_view_environment_id: #{hostgroup.errors.full_messages}"
      assert hostgroup.save

      # Verify persistence - reload and check database state
      hostgroup.reload
      assert_nil hostgroup.content_view_id, "Content view ID should be nil after removal"
      assert_nil hostgroup.lifecycle_environment_id, "Lifecycle environment ID should be nil after removal"
      assert_nil hostgroup.content_facet.content_view_environment_id, "ContentViewEnvironment association should be cleared"
    end

    def test_nil_content_view_environment_is_valid
      hostgroup = ::Hostgroup.create!(name: 'TestHG')

      # No content_view_environment_id is valid (no content management)
      hostgroup.content_view_environment_id = nil

      assert hostgroup.valid?, "Hostgroup should be valid with nil content_view_environment_id: #{hostgroup.errors.full_messages}"
    end

    def test_updating_content_view_environment_to_different_env
      hostgroup = ::Hostgroup.create!(name: 'TestHG')
      cvenv_lib = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      hostgroup.content_view_environment_id = cvenv_lib.id
      hostgroup.save!

      # Publish view to dev
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @dev)

      # Change to dev environment (CV is published to both)
      cvenv_dev = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @dev.id)
      hostgroup.content_view_environment_id = cvenv_dev.id

      assert hostgroup.valid?, "Hostgroup should be valid when changing to another CVEnv: #{hostgroup.errors.full_messages}"
      assert hostgroup.save
    end

    def test_child_can_set_different_content_view_environment_than_parent
      parent = ::Hostgroup.create!(name: 'ParentHG')
      cvenv_lib = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @library.id)
      parent.content_view_environment_id = cvenv_lib.id
      parent.save!

      child = ::Hostgroup.create!(name: 'ChildHG', parent: parent)

      # Publish view to dev
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @dev)

      # Child sets a different content_view_environment_id
      cvenv_dev = Katello::ContentViewEnvironment.find_by!(content_view_id: @view.id, environment_id: @dev.id)
      child.content_view_environment_id = cvenv_dev.id

      assert child.valid?, "Child should be valid when setting its own content_view_environment_id: #{child.errors.full_messages}"
      assert child.save

      # Verify the child has explicit CV and LCE values
      child.reload
      assert_equal @view.id, child.content_view_id, "Child should have explicitly set CV"
      assert_equal @dev.id, child.lifecycle_environment_id, "Child should have explicitly set LCE"
    end
  end
end
