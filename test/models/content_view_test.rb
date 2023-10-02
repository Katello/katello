require 'katello_test_helper'

module Katello
  class ContentViewTest < ActiveSupport::TestCase
    def setup
      User.current         = users(:admin)
      @organization        = get_organization
      @library             = katello_environments(:library)
      @dev                 = katello_environments(:dev)
      @default_view        = katello_content_views(:acme_default)
      @library_view        = katello_content_views(:library_view)
      @library_dev_view    = katello_content_views(:library_dev_view)
      @no_environment_view = katello_content_views(:no_environment_view)
    end

    def test_docker_promote
      org = @organization
      product = create(:katello_product, provider: org.anonymous_provider,
                       organization: org, name: 'Registry', label: 'registry')
      repo = create(:docker_repository, content_view_version: org.default_content_view.versions.first,
                    docker_upstream_name: 'image/one', :product => product)

      cv1 = create(:katello_content_view, organization: org,
                   name: 'CV1', label: 'cv1')
      cv1.repositories << repo
      cv1.save!
      cvv1repo1 = build(:docker_repository, product: product,
                        content_view_version: org.default_content_view.versions.first,
                        library_instance_id: repo.id)
      cvv1 = create(:katello_content_view_version, :content_view => cv1, :repositories => [cvv1repo1])

      env1 = create(:katello_environment, name: 'Env 1', label: 'env1', organization: org,
                    priors: [org.library])
      cvv1repo1.environment = env1
      cvv1repo1.save!
      create(:katello_content_view_environment,
             name: "#{env1.label}/#{cv1.label}", label: "#{env1.label}/#{cv1.label}",
             environment: env1, content_view: cv1, content_view_version: cvv1)

      cv2 = create(:katello_content_view, organization: org,
                   name: 'CV2', label: 'cv2')
      cv2.repositories << repo
      cv2.save!
      cvv2repo1 = build(:docker_repository, product: product,
                        content_view_version: org.default_content_view.versions.first,
                        library_instance_id: repo.id)
      cvv2 = create(:katello_content_view_version, :content_view => cv2, :repositories => [cvv2repo1])
      create(:katello_content_view_environment,
             name: "#{env1.label}/#{cv2.label}", label: "#{env1.label}/#{cv2.label}",
             environment: env1, content_view: cv2, content_view_version: cvv2)
      cvv2repo1.environment = env1

      assert cv2.check_docker_repository_names!([env1])

      env1.update(registry_name_pattern: 'abcdef')
      assert cvv1repo1.save!
      assert_raises(ActiveRecord::RecordInvalid) do
        cvv2repo1.save!
      end
    end

    should_not allow_values(*invalid_name_list).for(:name)
    should_not allow_values(*invalid_name_list).for(:label)

    def test_create
      assert ContentView.create(FactoryBot.attributes_for(:katello_content_view))
    end

    def test_create_solve_dependencies
      content_view = FactoryBot.build(:katello_content_view, solve_dependencies: true)
      assert content_view.save
    end

    def test_label
      content_view = FactoryBot.build(:katello_content_view)
      content_view.label = ""
      assert content_view.save
      assert content_view.label.present?
    end

    def test_create_with_name
      content_view = FactoryBot.build(:katello_content_view)
      content_view.name = ('a' * 256)
      refute content_view.valid?
      assert_equal 1, content_view.errors.size

      content_view.name = content_view.name[0...-1]
      assert content_view.valid?
    end

    def test_bad_name
      content_view = FactoryBot.build(:katello_content_view, :name => "")
      assert content_view.invalid?
      refute content_view.save
      assert_includes content_view.errors, :name
    end

    def test_duplicate_name
      attrs = FactoryBot.attributes_for(:katello_content_view,
                                         :name => @library_dev_view.name)
      assert_raises(ActiveRecord::RecordInvalid) do
        ContentView.create!(attrs)
      end
      cv = ContentView.create(attrs)
      refute cv.persisted?
      refute cv.save
    end

    def test_bad_label
      content_view = FactoryBot.build(:katello_content_view)
      content_view.label = "Bad Label"

      assert content_view.invalid?
      assert_equal 1, content_view.errors.size
      assert_includes content_view.errors, :label
    end

    def test_content_view_environments
      assert_includes @library_view.environments, @library
      assert_includes @library.content_views, @library_view
    end

    def test_promote
      skip "TODO: Fix content views"
      Repository.any_instance.stubs(:checksum_type).returns(nil)
      Repository.any_instance.stubs(:uri).returns('http://test_uri/')
      Repository.any_instance.stubs(:bootable_distribution).returns(nil)
      content_view = @library_view
      refute_includes content_view.environments, @dev
      content_view.promote(@library, @dev)

      assert_includes content_view.environments, @dev
      refute_empty ContentViewEnvironment.where(:content_view_id => content_view,
                                                :environment_id => @dev)
    end

    def test_destroy
      skip "TODO: Fix content views"
      count = ContentView.count
      refute @library_dev_view.destroy
      assert ContentView.exists?(@library_dev_view.id)
      assert_equal count, ContentView.count
      assert @library_view.destroy
      assert_equal count - 1, ContentView.count
    end

    def test_copy
      count = ContentView.count
      new_view = @library_dev_view.copy("new view name")

      assert_equal count + 1, ContentView.count
      assert_equal new_view.name, "new view name"
      assert_equal new_view.description, @library_dev_view.description
      assert_equal new_view.organization_id, @library_dev_view.organization_id
      assert_equal new_view.default, @library_dev_view.default
      assert_equal new_view.composite, @library_dev_view.composite
      assert_equal new_view.components, @library_dev_view.components
      assert_equal new_view.repositories, @library_dev_view.repositories
      assert_equal new_view.filters, @library_dev_view.filters
    end

    def test_copy_with_solve_dependencies
      content_view = FactoryBot.create(:katello_content_view, solve_dependencies: true)
      new_view = content_view.copy('another content view with dep solving')

      assert_equal content_view.solve_dependencies, new_view.solve_dependencies
    end

    def test_delete
      skip "TODO: Fix content views"
      view = @library_dev_view
      view.delete(@dev)
      refute_includes view.environments, @dev
    end

    def test_delete_last_env
      skip "TODO: Fix content views"
      view = @library_view
      view.delete(@library)
      assert_empty ContentView.where(:label => view.label)
    end

    def test_default_scope
      refute_empty ContentView.default
      assert_empty ContentView.default.select { |v| !v.default }
      assert_includes ContentView.default, @library.default_content_view
    end

    def test_non_default_scope
      refute_empty ContentView.non_default
      assert_empty ContentView.non_default.select { |v| v.default }
    end

    def test_destroy_content_view_versions
      skip "TODO: Fix content views"
      content_view = @library_view
      content_view_version = @library_view.versions.first
      refute_nil content_view_version
      assert content_view.destroy
      assert_nil ContentViewVersion.find_by_id(content_view_version.id)
    end

    def test_all_version_library_instances_empty
      assert_empty @no_environment_view.all_version_library_instances
    end

    def test_all_version_library_instances_not_empty
      refute_empty @library_view.all_version_library_instances
    end

    test_attributes :pid => '4a3b616d-53ab-4396-9a50-916d6c42a401'
    def test_should_create_composite
      view = ContentView.new(:name => "new content view", :organization_id => @organization.id)
      [false, true].each do |composite|
        view.composite = composite
        assert view.valid?, "Validation failed for content view create with valid composite value: #{composite}"
      end
    end

    test_attributes :pid => '068e3e7c-34ac-47cb-a1bb-904d12c74cc7'
    def test_should_create_with_valid_description
      view = ContentView.new(:name => "new content view", :organization_id => @organization.id)
      valid_name_list.each do |description|
        view.description = description
        assert view.valid?, "Validation failed for content view create with valid description: '#{description}', length: #{description.length}"
      end
    end

    test_attributes :pid => '15e6fa3a-1a65-4e7d-8d32-3a81227ac1c8'
    def test_should_update_name_with_valid_values
      view = ContentView.create!(:name => "org content view", :organization_id => @organization.id)
      valid_name_list.each do |name|
        view.name = name
        assert view.valid?, "Validation failed for content view update with valid name: '#{name}', length: #{name}"
      end
    end

    test_attributes :pid => '77883887-800f-412f-91a3-b2f7ed999c70'
    def test_should_not_update_label
      view = ContentView.create!(:name => "org content view", :label => 'org_content_view', :organization_id => @organization.id)
      view.label = 'new_org_content_view'
      refute view.valid?, "Validation passed for content view when updating label value"
    end

    def test_composite_content_views_with_repos
      view = ContentView.create!(:name => "Carcosa",
                                 :organization_id => @organization.id,
                                 :composite => true)

      assert_raises(ActiveRecord::RecordInvalid) do
        view.repositories << Repository.first
      end
      assert_empty view.repositories
    end

    def test_composite_content_view_no_dependency_resolution
      assert_raises(ActiveRecord::RecordInvalid) do
        ContentView.create!(:name => "should not work",
                            :organization_id => @organization.id,
                            :solve_dependencies => true,
                            :composite => true)
      end
    end

    def test_on_demand_repositories
      repo1 = katello_repositories(:rhel_6_x86_64)
      repo1.root.update(:download_policy => ::Katello::RootRepository::DOWNLOAD_ON_DEMAND)
      view1 = create(:katello_content_view, organization: @organization)
      view1.repositories << repo1
      assert_includes view1.on_demand_repositories, repo1

      repo2 = katello_repositories(:fedora_17_x86_64)
      repo2.root.update(:download_policy => ::Katello::RootRepository::DOWNLOAD_IMMEDIATE)
      view2 = create(:katello_content_view, organization: @organization)
      view2.repositories << repo2
      refute_includes view2.on_demand_repositories, repo2
    end

    def test_content_view_components
      assert_raises(ActiveRecord::RecordInvalid) do
        @library_dev_view.update!(:component_ids => [@library_view.versions.first.id])
      end

      # cannot add components to a non-composite view
      assert_raises(ActiveRecord::RecordInvalid) do
        ContentView.create!(:name => "Carcosa",
                            :organization_id => @organization.id,
                            :composite => false,
                            :component_ids => [@library_view.versions.first.id])
      end

      # can add composites to a composite
      assert ContentView.create!(:name => "Carcosa",
                                 :organization_id => @organization.id,
                                 :composite => true,
                                 :component_ids => [@library_view.versions.first.id])
    end

    def test_composite_views_with_composite_versions
      composite_view1 = create(:katello_content_view, :composite)
      composite_version1 = create(:katello_content_view_version, :content_view => composite_view1)
      composite = ContentView.find(katello_content_views(:composite_view).id)
      assert_raises(ActiveRecord::RecordInvalid) do
        composite.update!(:component_ids => [composite_version1.id])
      end

      component = ContentViewComponent.new(:composite_content_view => composite,
                                           :content_view_version => composite_version1
                                          )
      refute component.valid?
      refute component.save
    end

    def test_repositories_to_publish
      composite = ContentView.find(katello_content_views(:composite_view).id)
      v1 = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1).id)
      composite.update(:component_ids => [v1.id])
      repo_ids = composite.repositories_to_publish.map(&:id)
      assert_equal v1.repositories.archived.pluck(:id).sort, repo_ids.sort

      repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      assert_includes @library_view.repositories_to_publish.map(&:id), repo.id
    end

    def test_repo_conflicts
      composite = ContentView.find(katello_content_views(:composite_view).id)
      v1 = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1).id)
      v2 = ContentViewVersion.find(katello_content_view_versions(:library_dev_view_version).id)

      assert composite.update(component_ids: [v1.id, v2.id])
      assert_equal 0, composite.errors.count # docker and yum repos
      refute_empty composite.duplicate_repositories_to_publish
    end

    def test_repo_conflicts_non_composite
      view = ContentView.new
      view.repositories << katello_repositories(:fedora_17_x86_64)
      view.repositories << katello_repositories(:rhel_6_x86_64)

      assert view.repositories.to_a.all? { |repo| repo.library_instance? } #should all be library instances
      assert_empty view.duplicate_repositories_to_publish
    end

    def test_docker_repo_conflicts
      composite = ContentView.find(katello_content_views(:composite_view).id)
      product = create(:katello_product, provider: @organization.anonymous_provider, organization: @organization)

      repo = create(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first)
      repo.stubs(:container_repository_name).returns('repo')
      repo.stubs(:set_container_repository_name).returns('repo')
      repo.save!

      view1 = create(:katello_content_view, organization: @organization)
      view1.repositories << repo

      repo1 = Repository.new(root: repo.root, content_view_version: @organization.default_content_view.versions.first, library_instance_id: repo.id, :relative_path => '/foo')
      repo1.stubs(:container_repository_name).returns('repo1')
      repo1.stubs(:set_container_repository_name).returns('repo1')
      repo1.save!

      version1 = create(:katello_content_view_version, :content_view => view1, :repositories => [repo1])

      view2 = create(:katello_content_view, organization: @organization)
      view2.repositories << repo
      repo2 = build(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first, library_instance_id: repo.id)
      repo2.stubs(:container_repository_name).returns('repo2')
      repo2.stubs(:set_container_repository_name).returns('repo2')
      repo2.save!
      version2 = create(:katello_content_view_version, :content_view => view2, :repositories => [repo2])

      composite.update(component_ids: [version1.id, version2.id])

      refute composite.valid?
      assert_includes composite.errors, :base
      assert composite.errors.full_messages.first =~ /^Container Image repo '#{repo.name}' is present in multiple/
    end

    def test_docker_repo_container_name_overlap
      product = create(:katello_product, provider: @organization.anonymous_provider, organization: @organization)
      @dev.registry_name_pattern = "abcdef"

      repo1_lib = create(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first)
      view1 = create(:katello_content_view, organization: @organization)
      view1.repositories << repo1_lib
      repo1_cv = create(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first, library_instance_id: repo1_lib.id, environment: @dev)

      repo2_lib = create(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first)
      view2 = create(:katello_content_view, organization: @organization)
      view2.repositories << repo2_lib

      assert_equal repo1_cv.container_repository_name, "abcdef"
      error = assert_raises(ActiveRecord::RecordInvalid) do
        create(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first, library_instance_id: repo2_lib.id, environment: @dev)
      end
      match_regex = /.*Container repository name for repository .* is not unique and cannot be created in .*\. Its Container .* conflicts with an existing repository\..*/
      assert_match match_regex, error.message
    end

    def test_docker_repo_container_name_resolution # rubocop:disable Metrics/AbcSize
      composite = ContentView.find(katello_content_views(:composite_view).id)
      product = create(:katello_product, provider: @organization.anonymous_provider, organization: @organization)

      repo1_lib = create(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first)
      view1 = create(:katello_content_view, organization: @organization)
      view1.repositories << repo1_lib
      repo1_cv = create(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first, library_instance_id: repo1_lib.id)
      version1 = create(:katello_content_view_version, :content_view => view1, :repositories => [repo1_cv])

      repo2_lib = create(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first)
      view2 = create(:katello_content_view, organization: @organization)
      view2.repositories << repo2_lib
      repo2_cv = build(:docker_repository, product: product, content_view_version: @organization.default_content_view.versions.first, library_instance_id: repo2_lib.id)
      version2 = create(:katello_content_view_version, :content_view => view2, :repositories => [repo2_cv])

      composite.update(component_ids: [version1.id, version2.id])
      assert composite.valid?
      assert composite.check_docker_repository_names!([@dev])

      # ensure that all containers are stored with the proper auto-generated names
      [version1, version2].each do |version|
        name = "#{@dev.organization.name.downcase.sub!(" ", "_")}-"\
          "#{version.content_view.label.downcase}-"\
          "#{version.content_view.content_view_versions[0].version.sub!(".", "_")}-"\
          "#{version.repositories[0].product.label.downcase}-"\
          "#{version.repositories[0].name.downcase.sub!(" ", "_")}"
        assert_equal name, version.repositories[0].container_repository_name
      end
    end

    def test_unique_environments
      3.times do |i|
        ContentViewVersion.create!(:major => i + 2,
                                   :content_view => @library_dev_view)
      end
      @library_dev_view.add_environment(@library_dev_view.organization.library, ContentViewVersion.last)
      assert_equal 2, @library_dev_view.environments.length
    end

    def test_check_remove_from_environment!
      facets = ::Katello::Host::ContentFacet.in_content_views_and_environments(
        lifecycle_environments: [@dev]
      )
      host_ids = facets.joins(:host).select('hosts.id').pluck('hosts.id')
      facets.each do |facet|
        facet&.host&.subscription_facet&.destroy
        facet&.destroy
      end
      ::Host::Managed.where(id: host_ids).destroy_all
      assert @library_dev_view.check_remove_from_environment!(@dev)

      @host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @library_dev_view,
                                 :lifecycle_environment => @dev)

      assert_raises RuntimeError do
        @library_dev_view.check_remove_from_environment!(@dev)
      end
    end

    def test_check_ready_to_destroy!
      assert_raises(RuntimeError) do
        @library_dev_view.check_ready_to_destroy!
      end

      view = ContentView.create!(:name => "Cat",
                                 :organization => @organization
                                )
      assert view.check_ready_to_destroy!
    end

    def test_check_composite_action_allowed_when_setting_enabled
      # Testing composite content view restrictions (Setting: restrict_composite_view=true)
      Setting['restrict_composite_view'] = true

      library = KTEnvironment.find(katello_environments(:library).id)
      composite = ContentView.find(katello_content_views(:composite_view).id)
      # version with no envs
      library_view_version_1 = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1).id)
      # version in library & dev
      library_dev_view_version = ContentViewVersion.find(katello_content_view_versions(:library_dev_view_version).id)

      composite.component_ids = [library_view_version_1.id]
      composite.save!
      assert_raises RuntimeError do
        composite.check_composite_action_allowed!(library)
      end

      composite.component_ids = [library_dev_view_version.id]
      composite.save!
      assert composite.check_composite_action_allowed!(library)
    end

    def test_check_composite_action_allowed_when_setting_enabled_with_active_record_relation
      # Testing composite content view restrictions (Setting: restrict_composite_view=true)
      Setting['restrict_composite_view'] = true

      library = KTEnvironment.where(:id => katello_environments(:library).id)
      composite = ContentView.find(katello_content_views(:composite_view).id)
      # version with no envs
      library_view_version_1 = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1).id)
      # version in library & dev
      library_dev_view_version = ContentViewVersion.find(katello_content_view_versions(:library_dev_view_version).id)

      composite.component_ids = [library_view_version_1.id]
      composite.save!
      assert_raises RuntimeError do
        composite.check_composite_action_allowed!(library)
      end

      composite.component_ids = [library_dev_view_version.id]
      composite.save!
      assert composite.check_composite_action_allowed!(library)
    end

    def test_check_composite_action_allowed_when_setting_disabled
      # Testing the default behavior (Setting: restrict_composite_view=false)
      Setting['restrict_composite_view'] = false

      library = KTEnvironment.find(katello_environments(:library).id)
      composite = ContentView.find(katello_content_views(:composite_view).id)
      # version with no envs
      library_view_version_1 = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1).id)
      # version in library & dev
      library_dev_view_version = ContentViewVersion.find(katello_content_view_versions(:library_dev_view_version).id)

      composite.component_ids = [library_view_version_1.id]
      composite.save!
      assert composite.check_composite_action_allowed!(library)

      composite.component_ids = [library_dev_view_version.id]
      composite.save!
      assert composite.check_composite_action_allowed!(library)
    end

    def test_next_version
      cv = ContentView.create!(:name => "test",
                               :organization => @organization
                              )
      assert_equal 1, cv.next_version

      assert_equal 2, @library_dev_view.next_version
      assert_equal @library_dev_view.next_version - 1, @library_dev_view.versions.maximum(:major)

      assert @library_dev_view.create_new_version
      @library_dev_view.reload
      assert_equal 3, @library_dev_view.next_version
      assert_equal @library_dev_view.next_version - 1, @library_dev_view.versions.reload.maximum(:major)
    end

    def test_latest_version
      # if a version hasn't been published, latest version is not available
      assert_nil @no_environment_view.latest_version

      assert_equal "2.0", @library_view.latest_version

      @library_view.create_new_version
      @library_view.reload
      assert_equal "3.0", @library_view.latest_version
    end

    def test_add_repository_from_other_org
      other_org = create(:katello_organization)
      view = create(:katello_content_view, :default => false, :organization => other_org)
      repo = katello_repositories(:rhel_6_x86_64)

      error = assert_raises(ActiveRecord::RecordInvalid) do
        view.repositories << repo
        view.save!
      end

      assert_match(/Organization other than/, error.message)
    end

    def test_products
      refute_empty @library_view.products
      refute_empty @library_view.products.redhat
    end

    def test_add_repository_from_other_view
      view = @library_view
      bad_repo = Repository.find(katello_repositories(:fedora_17_x86_64_library_view_1).id)
      assert_raises(ActiveRecord::RecordInvalid) do
        view.repositories << bad_repo
        view.save!
      end
    end

    def test_search_name
      assert_equal @library_view, ContentView.search_for("name = \"#{@library_view.name}\"").first
    end

    def test_search_label
      assert_equal @library_view, ContentView.search_for("label = \"#{@library_view.label}\"").first
    end

    def test_search_organization_id
      assert_includes ContentView.search_for("organization_id = #{@library_view.organization_id}"), @library_view
    end

    def test_search_composite_false
      assert_includes ContentView.search_for("composite = false"), @library_view
    end

    def test_search_composite_true
      refute_includes ContentView.search_for("composite = true"), @library_view
    end

    def test_audit_on_content_view_creation
      content_view = FactoryBot.build(:katello_content_view, :name => "CV_Audit")
      assert_difference 'Audit.count' do
        content_view.save!
      end
      recent_audit = content_view.audits.last
      assert_equal 'create', recent_audit.action
    end

    def test_audit_on_content_view_destroy
      content_view = FactoryBot.build(:katello_content_view)
      content_view.save!
      assert_difference 'Audit.count' do
        content_view.destroy
      end
      recent_audit = Audit.last
      assert_equal 'Katello::ContentView', recent_audit.auditable_type
      assert_equal 'destroy', recent_audit.action
    end

    def test_import_only_composite
      cv = FactoryBot.build(:katello_content_view, :import_only, :composite)
      refute cv.valid?
    end

    def test_import_only_dep_solve
      cv = FactoryBot.build(:katello_content_view, :import_only, solve_dependencies: true)
      refute cv.valid?
    end

    def test_import_only_immutable
      cv = FactoryBot.create(:katello_content_view, :import_only)
      cv.import_only = false
      refute cv.valid?
    end

    def test_update_host_statuses
      other_location = taxonomies(:location2)
      facet = katello_content_facets(:content_facet_two)

      refute_equal facet.host.location, other_location
      assert_nothing_raised do
        Location.as_taxonomy(facet.host.organization, other_location) do
          facet.content_view_environments.each do |cve|
            cve.content_view.update_host_statuses(cve.lifecycle_environment)
          end
        end
      end
    end

    def test_new_cv_needs_publish
      content_view = FactoryBot.build(:katello_content_view, :name => "New CV")
      content_view.save!
      assert content_view.needs_publish?
    end

    def test_audits_cleaned_cv_needs_publish
      content_view = FactoryBot.build(:katello_content_view, :name => "New CV cleaned audits")
      content_view.save!
      content_view.create_new_version
      task = ForemanTasks::Task.create!(:label => 'Actions::Katello::ContentView::Publish', :state => 'stopped',
                                        :type => 'ForemanTasks::Task::DynflowTask', :result => 'success')
      ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => content_view.latest_version_object.id,
                                                         :status => 'successful', :task_id => task.id, :user => User.first,
                                                         :action => "publish")
      content_view.reload
      content_view.latest_version_object.audits.destroy_all
      assert_nil content_view.needs_publish?
    end

    def test_audits_never_created_cv_needs_publish
      content_view = FactoryBot.build(:katello_content_view, :name => "New CV applied filters nil")
      content_view.save!
      content_view.create_new_version
      task = ForemanTasks::Task.create!(:label => 'Actions::Katello::ContentView::Publish', :state => 'stopped',
                                        :type => 'ForemanTasks::Task::DynflowTask', :result => 'success')
      ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => content_view.latest_version_object.id,
                                                         :status => 'successful', :task_id => task.id, :user => User.first,
                                                         :action => "publish")
      content_view.reload
      content_view.latest_version_object.update!(applied_filters: nil)
      assert_nil content_view.needs_publish?
    end

    def test_published_cv_needs_publish_on_dependency_solving_update
      org = @organization
      content_view = FactoryBot.build(:katello_content_view, :name => "New CV")
      content_view.organization_id = org.id
      content_view.save!
      assert content_view.needs_publish? #New CV needs publish
      content_view.create_new_version
      content_view.latest_version_object.update!(applied_filters: {"dependency_solving": false})
      task = ForemanTasks::Task.create!(:label => 'Actions::Katello::ContentView::Publish', :state => 'stopped',
                                        :type => 'ForemanTasks::Task::DynflowTask', :result => 'success')
      ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => content_view.latest_version_object.id,
                                            :status => 'successful', :task_id => task.id, :user => User.first,
                                            :action => "publish")
      content_view.reload
      refute content_view.needs_publish? #CV with newly created version doesn't need publish
      content_view.update!(solve_dependencies: true)
      assert content_view.needs_publish? #CV with updated dep_solving needs publish
      content_view.update!(solve_dependencies: false)
      refute content_view.needs_publish? #CV with same dep_solving doesn't need publish
    end

    def test_published_cv_needs_publish_on_repositories_update
      org = @organization
      product = create(:katello_product, provider: org.anonymous_provider,
                       organization: org, name: 'Registry', label: 'registry')
      repo = create(:docker_repository, content_view_version: org.default_content_view.versions.first,
                    docker_upstream_name: 'image/one', :product => product)

      content_view = FactoryBot.build(:katello_content_view, :name => "New CV")
      content_view.organization_id = org.id
      content_view.save!
      assert content_view.needs_publish? #New CV needs publish
      content_view.create_new_version
      task = ForemanTasks::Task.create!(:label => 'Actions::Katello::ContentView::Publish', :state => 'stopped',
                                        :type => 'ForemanTasks::Task::DynflowTask', :result => 'success')
      ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => content_view.latest_version_object.id,
                                                         :status => 'successful', :task_id => task.id, :user => User.first,
                                                         :action => "publish")
      content_view.reload
      refute content_view.needs_publish? #CV with newly created version doesn't need publish
      content_view.update!(repository_ids: [repo.id])
      assert content_view.needs_publish? #CV with newly updated repositories needs publish
    end

    def test_published_cv_needs_publish_on_repository_publication_update
      org = @organization
      product = create(:katello_product, provider: org.anonymous_provider,
                       organization: org, name: 'Registry', label: 'registry')
      repo = create(:docker_repository, content_view_version: org.default_content_view.versions.first,
                    docker_upstream_name: 'image/one', :product => product)

      content_view = FactoryBot.build(:katello_content_view, :name => "New CV")
      content_view.organization_id = org.id
      content_view.repository_ids = [repo.id]
      content_view.save!
      assert content_view.needs_publish? #New CV needs publish
      content_view.create_new_version
      task = ForemanTasks::Task.create!(:label => 'Actions::Katello::ContentView::Publish', :state => 'stopped',
                                        :type => 'ForemanTasks::Task::DynflowTask', :result => 'success')
      ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => content_view.latest_version_object.id,
                                                         :status => 'successful', :task_id => task.id, :user => User.first,
                                                         :action => "publish")
      content_view.reload
      refute content_view.needs_publish? #CV with newly created version doesn't need publish
      repo.update!(publication_href: "Updated_href")
      assert content_view.needs_publish? #CV needs publish when child repo gets new publication
    end

    def test_nil_on_failed_cv_publish_needs_publish
      content_view = FactoryBot.build(:katello_content_view, :name => "New CV")
      content_view.save!
      assert content_view.needs_publish? #no version needs publish
      content_view.create_new_version
      task = ForemanTasks::Task.create!(:label => 'Actions::Katello::ContentView::Publish', :state => 'stopped',
                                        :type => 'ForemanTasks::Task::DynflowTask', :result => 'failed')
      ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => content_view.latest_version_object.id,
                                                         :status => 'successful', :task_id => task.id, :user => User.first,
                                                         :action => "publish")
      assert_nil content_view.needs_publish?
    end

    def test_ignore_generated
      assert_equal Katello::ContentView.generated_for_library_export.count, 1
      assert_equal Katello::ContentView.generated_for_library_import.count, 1
      ignore_generated = Katello::ContentView.ignore_generated(include_library_generated: false).count
      ignore_generated_include_library = Katello::ContentView.ignore_generated(include_library_generated: true).count
      assert_equal (ignore_generated - ignore_generated_include_library), 2
    end
  end
end
