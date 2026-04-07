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

      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      assert_includes @root.organizations, @library.organization
    end

    def test_inherited_lifecycle_environment_with_ancestry
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      assert_equal @library, @child.lifecycle_environment
      assert_equal @library, @root.lifecycle_environment
    end

    def test_inherited_content_view_with_ancestry
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      assert_equal @view, @child.content_view
      assert_equal @view, @root.content_view
    end

    def test_inherited_content_view_with_ancestry_nill
      @child.content_view = @view
      @child.lifecycle_environment = @library
      @child.save!

      assert_equal @view, @child.content_view
      assert_nil @root.content_view
    end

    def test_inherited_lifecycle_environment_with_ancestry_nil
      @child.content_view = @view
      @child.lifecycle_environment = @library
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

      host_group = ::Hostgroup.new(:name => 'test_cv_hostgroup',
                                    :content_view => content_view,
                                    :lifecycle_environment => @library)
      assert_valid host_group
      assert_equal content_view, host_group.content_view
    end

    def test_update_content_view
      @root.content_view = @view
      @root.lifecycle_environment = @library
      assert @root.save!
      assert_equal @view, @root.reload.content_view

      new_view = FactoryBot.create(:katello_content_view, organization: @org)
      new_view_version = FactoryBot.create(:katello_content_view_version, content_view: new_view)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: new_view_version,
                        environment: @library)

      @root.content_view = new_view
      @root.lifecycle_environment = @library
      assert @root.save!
      assert_equal new_view, @root.reload.content_view
    end

    def test_remove_content_view
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!
      assert_equal @view, @root.content_view

      # Removing content_view_id removes the CVE association, making both nil
      @root.content_facet.content_view_environment = nil
      @root.save!
      assert_nil @root.reload.content_view
    end

    def test_content_view_delegation_to_facet
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      assert_equal @view.id, @root.content_view_id
      assert_equal @view.name, @root.content_view_name
    end

    def test_content_view_inheritance_multiple_levels
      grandparent = ::Hostgroup.create!(:name => 'grandparent')
      parent = ::Hostgroup.create!(:name => 'parent', :parent => grandparent)
      child = ::Hostgroup.create!(:name => 'child', :parent => parent)

      # Set content view on grandparent
      grandparent.content_view = @view
      grandparent.lifecycle_environment = @library
      grandparent.save!

      # Both parent and child should inherit
      assert_equal @view, parent.content_view
      assert_equal @view, child.content_view
    end

    def test_content_view_override_in_child
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      different_view = FactoryBot.create(:katello_content_view, organization: @org)
      different_view_version = FactoryBot.create(:katello_content_view_version, content_view: different_view)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: different_view_version,
                        environment: @library)

      @child.content_view = different_view
      @child.lifecycle_environment = @library
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

      grandparent.content_view = grandparent_view
      grandparent.lifecycle_environment = @library
      grandparent.save!

      parent.content_view = parent_view
      parent.lifecycle_environment = @library
      parent.save!

      # Child should inherit from closest ancestor (parent)
      assert_equal parent_view, child.content_view
      assert_equal parent_view, parent.content_view
      assert_equal grandparent_view, grandparent.content_view
    end

    def test_lifecycle_environment_auto_adds_organization
      # When setting CV and LCE together (required by validation),
      # the lifecycle_environment triggers add_organization_for_environment callback
      org = @view.organization

      # Ensure hostgroup doesn't have the org initially
      @root.organizations = []
      @root.save!

      # Set both CV and LCE together (required by validation)
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      # With CVEnv model, setting CV and LCE together triggers add_organization_for_environment
      # So organization WILL be auto-added
      @root.reload
      assert_includes @root.organizations, org
    end

    def test_rhsm_organization_label_from_content_view
      # With CVEnv model, both CV and LCE are always set together
      # This test now verifies the logic returns org label when both are present
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      # Should use lifecycle environment's org (same as content_view org in this case)
      assert_equal @view.organization.label, @root.rhsm_organization_label
    end

    def test_rhsm_organization_label_prefers_lifecycle_environment
      @root.lifecycle_environment = @library
      @root.content_view = @view
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

      # Setting content_view should create facet
      hostgroup.content_view = @view
      assert_not_nil hostgroup.content_facet
    end

    def test_inherited_content_view_id
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      # Child should inherit content_view_id
      assert_equal @view.id, @child.inherited_content_view_id
      assert_nil @child.content_view_id
    end

    def test_content_view_with_lifecycle_environment_validation
      # With CVE model, validation is implicit - CVE must exist to be assigned
      # Create a content view that is ONLY published to library, not dev
      library_only_view = FactoryBot.create(:katello_content_view, organization: @org)
      library_only_version = FactoryBot.create(:katello_content_view_version, content_view: library_only_view)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: library_only_version,
                        environment: @library) # Only in library, not dev

      @root.lifecycle_environment = @dev # dev environment
      @root.content_view = library_only_view # Only published to library, not dev

      # With ContentViewEnvironmentValidator: should reject CV not published to environment
      refute @root.valid?, "Should be invalid when CV not published to selected environment"
      # The validator adds the error to the content_facet's base errors
      assert @root.content_facet.errors[:base].present?, "Should have validation error on content facet"
    end

    def test_create_with_lifecycle_environment
      host_group = ::Hostgroup.new(:name => 'test_le_hostgroup',
                                    :content_view => @view,
                                    :lifecycle_environment => @dev)
      assert_valid host_group
      assert_equal @dev, host_group.lifecycle_environment
    end

    def test_update_lifecycle_environment
      @root.content_view = @view
      @root.lifecycle_environment = @library
      assert @root.save!
      assert_equal @library, @root.reload.lifecycle_environment

      @root.content_view = @view
      @root.lifecycle_environment = @dev
      assert @root.save!
      assert_equal @dev, @root.reload.lifecycle_environment
    end

    def test_remove_lifecycle_environment
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!
      assert_equal @library, @root.lifecycle_environment

      # Removing CVE association removes both CV and LE
      @root.content_facet.content_view_environment = nil
      @root.save!
      assert_nil @root.reload.lifecycle_environment
    end

    def test_lifecycle_environment_delegation_to_facet
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      assert_equal @library.id, @root.lifecycle_environment_id
      assert_equal @library.name, @root.lifecycle_environment_name
    end

    def test_lifecycle_environment_inheritance_multiple_levels
      grandparent = ::Hostgroup.create!(:name => 'gp_le')
      parent = ::Hostgroup.create!(:name => 'p_le', :parent => grandparent)
      child = ::Hostgroup.create!(:name => 'c_le', :parent => parent)

      # Set lifecycle environment on grandparent
      grandparent.content_view = @view
      grandparent.lifecycle_environment = @library
      grandparent.save!

      # Both parent and child should inherit
      assert_equal @library, parent.lifecycle_environment
      assert_equal @library, child.lifecycle_environment
    end

    def test_lifecycle_environment_override_in_child
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      @child.content_view = @view
      @child.lifecycle_environment = @dev
      @child.save!

      # Parent has its env, child has overridden env
      assert_equal @library, @root.lifecycle_environment
      assert_equal @dev, @child.lifecycle_environment
    end

    def test_lifecycle_environment_inheritance_respects_closest_ancestor
      grandparent = ::Hostgroup.create!(:name => 'gp_le2')
      parent = ::Hostgroup.create!(:name => 'p_le2', :parent => grandparent)
      child = ::Hostgroup.create!(:name => 'c_le2', :parent => parent)

      grandparent.content_view = @view
      grandparent.lifecycle_environment = @library
      grandparent.save!

      parent.content_view = @view
      parent.lifecycle_environment = @dev
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
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      # Child should inherit lifecycle_environment_id
      assert_equal @library.id, @child.inherited_lifecycle_environment_id
      assert_nil @child.lifecycle_environment_id
    end

    def test_lifecycle_environment_creates_facet_if_missing
      hostgroup = ::Hostgroup.create!(:name => 'no_facet_le')
      assert_nil hostgroup.content_facet

      # Setting lifecycle_environment should create facet
      hostgroup.lifecycle_environment = @library
      assert_not_nil hostgroup.content_facet
    end

    def test_rhsm_organization_label_from_lifecycle_environment
      # With CVE model, both CV and LE are always set together
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      assert_equal @library.organization.label, @root.rhsm_organization_label
    end

    def test_lifecycle_environment_organization_auto_added
      org = @library.organization

      # Ensure hostgroup doesn't have the org initially
      @root.organizations = []
      @root.save!

      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.save!

      # Organization should be added automatically via callback
      @root.reload
      assert_includes @root.organizations, org
    end

    def test_lifecycle_environment_with_content_view_same_org
      # CV must be published to LE for validation to pass
      # @view (library_dev_staging_view) IS published to @library
      @root.lifecycle_environment = @library
      @root.content_view = @view

      assert @root.valid?
      assert @root.save!
    end

    def test_lifecycle_environment_and_content_view_not_published_together
      # With CVE model, if CV is not published to LE, the CVE doesn't exist
      # Create a view only published to library
      library_only_view = FactoryBot.create(:katello_content_view, organization: @org)
      library_only_version = FactoryBot.create(:katello_content_view_version, content_view: library_only_view)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: library_only_version,
                        environment: @library) # Only in library

      @root.lifecycle_environment = @dev # dev environment
      @root.content_view = library_only_view # Only published to library

      # With ContentViewEnvironmentValidator: should reject CV not published to environment
      refute @root.valid?, "Should be invalid when CV not published to selected environment"
      # The validator adds the error to the content_facet's base errors
      assert @root.content_facet.errors[:base].present?, "Should have validation error on content facet"
    end

    def test_change_lifecycle_environment_updates_children
      parent = ::Hostgroup.create!(:name => 'parent_le_change')
      child = ::Hostgroup.create!(:name => 'child_le_change', :parent => parent)
      grandchild = ::Hostgroup.create!(:name => 'grandchild_le_change', :parent => child)

      parent.content_view = @view
      parent.lifecycle_environment = @library
      parent.save!

      # All should inherit
      assert_equal @library, child.lifecycle_environment
      assert_equal @library, grandchild.lifecycle_environment

      # Change parent's env
      parent.content_view = @view
      parent.lifecycle_environment = @dev
      parent.save!

      # Children should now inherit new value
      assert_equal @dev, child.reload.lifecycle_environment
      assert_equal @dev, grandchild.reload.lifecycle_environment
    end

    def test_child_override_persists_when_parent_changes
      parent = ::Hostgroup.create!(:name => 'parent_override')
      child = ::Hostgroup.create!(:name => 'child_override', :parent => parent)

      parent.content_view = @view
      parent.lifecycle_environment = @library
      parent.save!

      # Child explicitly sets different env
      child.content_view = @view
      child.lifecycle_environment = @dev
      child.save!

      # Change parent
      parent.content_view = @view
      parent.lifecycle_environment = @staging
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

      grandparent.content_view = @view1
      grandparent.lifecycle_environment = @library
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

      grandparent.content_view = @view1
      grandparent.lifecycle_environment = @library
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
      parent.content_view = @view1
      parent.lifecycle_environment = @library
      parent.save!

      # Child1 inherits
      assert_equal @view1, child1.content_view

      # Child2 overrides
      child2.content_view = @view2
      child2.lifecycle_environment = @library
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
      grandparent.content_view = @view1
      grandparent.lifecycle_environment = @library
      grandparent.save!

      # Override in parent2
      parent2.content_view = @view1
      parent2.lifecycle_environment = @dev
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
      level1.content_view = @view1
      level1.lifecycle_environment = @library
      level1.save!

      # All inherit initially
      assert_equal @view1, level2.content_view
      assert_equal @view1, level3.content_view
      assert_equal @view1, level4.content_view

      # Override at middle level (level2)
      level2.content_view = @view2
      level2.lifecycle_environment = @library
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

      grandparent.content_view = @view1
      grandparent.lifecycle_environment = @library
      grandparent.save!

      # Parent inherits
      assert_equal @library, parent.lifecycle_environment

      # Grandchild sets different value
      grandchild.content_view = @view1
      grandchild.lifecycle_environment = @staging
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
      grandparent.content_view = @view1
      grandparent.lifecycle_environment = @library
      grandparent.save!

      # Override only CV at parent level (LE stays inherited)
      parent.content_view = @view2
      parent.lifecycle_environment = @library
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
      grandparent.content_view = @view1
      grandparent.lifecycle_environment = @library
      grandparent.save!

      parent.content_view = @view2
      parent.lifecycle_environment = @library
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
      level1.content_view = @view1
      level1.lifecycle_environment = @library
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
      root.content_view = @view1
      root.lifecycle_environment = @library
      root.save!

      # All should inherit
      assert_equal @view1, a1.content_view
      assert_equal @view1, a2.content_view
      assert_equal @view1, a3.content_view
      assert_equal @view1, b1.content_view
      assert_equal @view1, b2.content_view
      assert_equal @view1, b3.content_view

      # Override one branch
      a2.content_view = @view2
      a2.lifecycle_environment = @library
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
      facet.content_view = @distro_cv
      facet.content_source = @content_source
      facet.lifecycle_environment = @distro_env
      facet.kickstart_repository = @distro
      assert facet.save
      assert_valid facet
      assert_equal hg.reload.kickstart_repository, @distro
    end

    def test_set_kickstart_repository
      @os.stubs(:kickstart_repos).returns([@distro])
      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        kickstart_repository: @distro)

      assert_valid hg
      assert_equal hg.kickstart_repository, @distro
    end

    def test_set_installation_medium
      hg = ::Hostgroup.new(
        name: 'install_media',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        medium: @medium)

      assert_valid hg
      assert_equal hg.medium, @medium
    end

    def test_change_medium_to_kickstart_repository
      @os.stubs(:kickstart_repos).returns([@distro])
      hg = ::Hostgroup.new(
        name: 'install_media',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        medium: @medium)

      assert hg.save
      hg.kickstart_repository = @distro
      assert_valid hg
      assert_nil hg.medium
      assert_equal hg.kickstart_repository, @distro
    end

    def test_change_kickstart_repository_to_medium
      @os.stubs(:kickstart_repos).returns([@distro])
      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        kickstart_repository: @distro)

      assert hg.save
      hg.medium = @medium
      assert_valid hg
      assert_nil hg.kickstart_repository
      assert_equal hg.medium, @medium
    end

    def test_change_lifecycle_environment_mismatched_kickstart
      @os = ::Redhat.create_operating_system("GreatOS1", *@dev_distro.distribution_version.split('.'))

      hg = ::Hostgroup.new(
        name: 'kickstart_repo',
        operatingsystem: @os,
        content_source: @content_source,
        architecture: @arch,
        content_view: @distro_cv,
        lifecycle_environment: @distro_env,
        kickstart_repository: @distro)

      # changing the lifecycle environment will trigger
      # code which attempts to reassign the kickstart repo by its label
      hg.lifecycle_environment = @dev_distro.environment
      assert hg.save
      assert_equal hg.kickstart_repository_id, @dev_distro.id
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

      @hg_with_view1 = ::Hostgroup.create!(name: 'hg_cv1')
      @hg_with_view1.content_view = @view1
      @hg_with_view1.lifecycle_environment = @library
      @hg_with_view1.save!

      @hg_with_view2 = ::Hostgroup.create!(name: 'hg_cv2')
      @hg_with_view2.content_view = @view2
      @hg_with_view2.lifecycle_environment = @library
      @hg_with_view2.save!

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

      # Create CVEs for view in each environment
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @library)
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @dev)

      @hg_with_library = ::Hostgroup.create!(name: 'hg_lib')
      @hg_with_library.content_view = @view
      @hg_with_library.lifecycle_environment = @library
      @hg_with_library.save!

      @hg_with_dev = ::Hostgroup.create!(name: 'hg_dev')
      @hg_with_dev.content_view = @view
      @hg_with_dev.lifecycle_environment = @dev
      @hg_with_dev.save!

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
      parent.content_view = @view
      parent.lifecycle_environment = @staging
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

    def test_setting_content_view_without_lifecycle_environment_should_fail
      hostgroup = ::Hostgroup.create!(name: 'TestHG')

      # Try to set only CV without LCE
      hostgroup.content_view_id = @view.id
      # Don't set lifecycle_environment_id

      refute hostgroup.valid?, "Hostgroup should be invalid when setting CV without LCE"
      assert_includes hostgroup.errors.messages.to_s, 'Content view', "Should have validation error about content view"
    end

    def test_setting_lifecycle_environment_without_content_view_should_fail
      hostgroup = ::Hostgroup.create!(name: 'TestHG')

      # Try to set only LCE without CV
      hostgroup.lifecycle_environment_id = @library.id
      # Don't set content_view_id

      refute hostgroup.valid?, "Hostgroup should be invalid when setting LCE without CV"
      assert hostgroup.errors.messages.to_s.include?('Content view') || hostgroup.errors.messages.to_s.include?('Lifecycle environment'),
             "Should have validation error about missing CV or LCE"
    end

    def test_setting_both_content_view_and_lifecycle_environment_should_succeed
      hostgroup = ::Hostgroup.create!(name: 'TestHG')

      # Set both CV and LCE together
      hostgroup.lifecycle_environment_id = @library.id
      hostgroup.content_view_id = @view.id

      assert hostgroup.valid?, "Hostgroup should be valid when setting both CV and LCE: #{hostgroup.errors.full_messages}"
      assert hostgroup.save
    end

    def test_removing_both_content_view_and_lifecycle_environment_should_succeed
      hostgroup = ::Hostgroup.create!(name: 'TestHG')
      hostgroup.lifecycle_environment_id = @library.id
      hostgroup.content_view_id = @view.id
      hostgroup.save!

      # Remove both together
      hostgroup.lifecycle_environment_id = nil
      hostgroup.content_view_id = nil

      assert hostgroup.valid?, "Hostgroup should be valid when removing both CV and LCE: #{hostgroup.errors.full_messages}"
      assert hostgroup.save

      # Verify persistence - reload and check database state
      hostgroup.reload
      assert_nil hostgroup.content_view_id, "Content view ID should be nil after removal"
      assert_nil hostgroup.lifecycle_environment_id, "Lifecycle environment ID should be nil after removal"
      assert_nil hostgroup.content_facet.content_view_environment_id, "ContentViewEnvironment association should be cleared"
    end

    def test_nil_content_view_with_nil_lifecycle_environment_is_valid
      hostgroup = ::Hostgroup.create!(name: 'TestHG')

      # Both nil is valid (no content management)
      hostgroup.lifecycle_environment_id = nil
      hostgroup.content_view_id = nil

      assert hostgroup.valid?, "Hostgroup should be valid with both CV and LCE as nil: #{hostgroup.errors.full_messages}"
    end

    def test_updating_lifecycle_environment_keeps_content_view_valid
      hostgroup = ::Hostgroup.create!(name: 'TestHG')
      hostgroup.lifecycle_environment_id = @library.id
      hostgroup.content_view_id = @view.id
      hostgroup.save!

      # Publish view to dev
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @dev)

      # Change environment (CV is published to both)
      hostgroup.lifecycle_environment_id = @dev.id

      assert hostgroup.valid?, "Hostgroup should be valid when changing LCE to another env where CV is published: #{hostgroup.errors.full_messages}"
      assert hostgroup.save
    end

    def test_child_can_set_partial_cv_lce_when_parent_has_other
      parent = ::Hostgroup.create!(name: 'ParentHG')
      parent.lifecycle_environment_id = @library.id
      parent.content_view_id = @view.id
      parent.save!

      child = ::Hostgroup.create!(name: 'ChildHG', parent: parent)

      # Publish view to dev
      FactoryBot.create(:katello_content_view_environment,
                        content_view_version: @view_version,
                        environment: @dev)

      # Child must set both CV and LCE explicitly, even when inheriting from parent
      # Setting only LCE would fail validation because the "both together" rule
      # checks pending values, not inherited values
      child.lifecycle_environment_id = @dev.id
      child.content_view_id = @view.id # Must explicitly set, even though parent has it

      assert child.valid?, "Child should be valid when setting both CV and LCE explicitly: #{child.errors.full_messages}"
      assert child.save

      # Verify the child has explicit CV and LCE values
      child.reload
      assert_equal @view.id, child.content_view_id, "Child should have explicitly set CV"
      assert_equal @dev.id, child.lifecycle_environment_id, "Child should have explicitly set LCE"
    end
  end
end
