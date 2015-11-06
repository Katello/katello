require 'katello_test_helper'

module Katello
  class ContentViewTest < ActiveSupport::TestCase
    def setup
      User.current         = User.find(users(:admin))
      @organization        = get_organization
      @library             = KTEnvironment.find(katello_environments(:library).id)
      @dev                 = KTEnvironment.find(katello_environments(:dev).id)
      @default_view        = ContentView.find(katello_content_views(:acme_default).id)
      @library_view        = ContentView.find(katello_content_views(:library_view).id)
      @library_dev_view    = ContentView.find(katello_content_views(:library_dev_view).id)
      @no_environment_view = ContentView.find(katello_content_views(:no_environment_view).id)
    end

    def test_create
      assert ContentView.create(FactoryGirl.attributes_for(:katello_content_view))
    end

    def test_label
      content_view = FactoryGirl.build(:katello_content_view)
      content_view.label = ""
      assert content_view.save
      assert content_view.label.present?
    end

    def test_create
      content_view = FactoryGirl.build(:katello_content_view)
      assert content_view.save
    end

    def test_create_with_name
      content_view = FactoryGirl.build(:katello_content_view)
      content_view.name = ('a' * 256)
      refute content_view.valid?
      assert_equal 1, content_view.errors.size

      content_view.name = content_view.name[0...-1]
      assert content_view.valid?
    end

    def test_bad_name
      content_view = FactoryGirl.build(:katello_content_view, :name => "")
      assert content_view.invalid?
      refute content_view.save
      assert content_view.errors.include?(:name)
    end

    def test_duplicate_name
      attrs = FactoryGirl.attributes_for(:katello_content_view,
                                         :name => @library_dev_view.name
                                        )
      assert_raises(ActiveRecord::RecordInvalid) do
        ContentView.create!(attrs)
      end
      cv = ContentView.create(attrs)
      refute cv.persisted?
      refute cv.save
    end

    def test_bad_label
      content_view = FactoryGirl.build(:katello_content_view)
      content_view.label = "Bad Label"

      assert content_view.invalid?
      assert_equal 1, content_view.errors.size
      assert content_view.errors.include?(:label)
    end

    def test_content_view_environments
      assert_includes @library_view.environments, @library
      assert_includes @library.content_views, @library_view
    end

    def test_environment_content_view_env_destroy_should_fail
      User.current = User.find(users(:admin))
      ContentViewPuppetEnvironment.any_instance.stubs(:clear_content_indices)
      env = @dev
      cve = env.content_views.first.content_view_environments.where(:environment_id => env.id).first
      assert_raises(RuntimeError) do
        env.destroy!
      end
      refute_nil ContentViewEnvironment.find_by_id(cve.id)
    end

    def test_promote
      skip "TODO: Fix content views"
      Repository.any_instance.stubs(:clone_contents).returns([])
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

    def test_composite_content_views_with_repos
      view = ContentView.create!(:name => "Carcosa",
                                 :organization_id => @organization.id,
                                 :composite => true)

      assert_raises(ActiveRecord::RecordInvalid) do
        view.repositories << Repository.first
      end
      assert_empty view.repositories
    end

    def test_content_view_components
      assert_raises(ActiveRecord::RecordInvalid) do
        @library_dev_view.update_attributes!(:component_ids => [@library_view.versions.first.id])
      end

      component = ContentViewComponent.new(:content_view => @library_dev_view,
                                           :content_view_version => @library_view.versions.first
                                          )
      refute component.valid?
      refute component.save
    end

    def test_composite_views_with_composite_versions
      ContentViewVersion.any_instance.stubs(:puppet_modules).returns([])
      view = stub(:composite? => true)
      view.stubs(:default?).returns(false)
      ContentViewVersion.any_instance.stubs(:content_view).returns(view)
      composite = ContentView.find(katello_content_views(:composite_view))
      v1 = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1))
      assert_raises(ActiveRecord::RecordInvalid) do
        composite.update_attributes(:component_ids => [v1.id])
      end

      component = ContentViewComponent.new(:content_view => composite,
                                           :content_view_version => v1
                                          )
      refute component.valid?
      refute component.save
    end

    def test_repositories_to_publish
      ContentViewVersion.any_instance.stubs(:puppet_modules).returns([])
      composite = ContentView.find(katello_content_views(:composite_view))
      v1 = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1))
      composite.update_attributes(:component_ids => [v1.id])
      repo_ids = composite.repositories_to_publish.map(&:id)
      assert_equal v1.repositories.archived.pluck(:id).sort, repo_ids.sort

      repo = Repository.find(katello_repositories(:fedora_17_x86_64))
      assert_includes @library_view.repositories_to_publish.map(&:id), repo.id
    end

    def test_repo_conflicts
      ContentViewVersion.any_instance.stubs(:puppet_modules).returns([])
      composite = ContentView.find(katello_content_views(:composite_view))
      v1 = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1))
      v2 = ContentViewVersion.find(katello_content_view_versions(:library_view_version_2))

      refute composite.update_attributes(component_ids: [v1.id, v2.id])
      assert_equal 2, composite.errors.count # docker and yum repos
      assert composite.errors.full_messages.first =~ /^Repository conflict/

      assert_raises(RuntimeError) do
        composite.components << v1
      end
    end

    def test_puppet_module_conflicts
      composite = ContentView.find(katello_content_views(:composite_view))
      view = create(:katello_content_view)
      versions = 2.times.map do |_i|
        create(:katello_content_view_version, :content_view => view)
      end
      ContentViewVersion.any_instance.stubs(:puppet_modules).returns([stub(:name => "httpd")]).times(4)

      refute composite.update_attributes(component_ids: versions.map(&:id))
      assert_equal 1, composite.errors.count
      assert composite.errors.full_messages.first =~ /^Puppet module conflict/

      assert_raises(RuntimeError) do
        composite.components << versions.first
      end
    end

    def test_puppet_repos
      @p_forge = Repository.find(katello_repositories(:p_forge))

      assert_raises(ActiveRecord::RecordInvalid) do
        @library_view.repositories << @p_forge
      end
    end

    def test_iso_repos
      @file_repo = create(:katello_repository, :iso, :product => @organization.products.first, :content_view_version =>
          @organization.default_content_view.versions.first)

      assert_raises(ActiveRecord::RecordInvalid) do
        @library_view.repositories << @file_repo
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
      assert @library_dev_view.check_remove_from_environment!(@dev)

      System.create!(:name => "Gregor Somosa",
                     :cp_type => "system",
                     :facts => {:foo => :bar},
                     :environment => @dev,
                     :content_view => @library_dev_view
                    )
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

    def test_check_distribution_conflicts_conflict
      view = @library_view
      view.repositories << Repository.find(katello_repositories(:rhel_6_x86_64))
      view.save!

      assert_raises(RuntimeError) do
        view.check_distribution_conflicts!
      end
    end

    def test_check_distribution_conflicts_no_conflict
      view = @library_view
      view.repositories << Repository.find(katello_repositories(:rhel_7_x86_64))
      view.repositories << Repository.find(katello_repositories(:feedless_fedora_17_x86_64))
      view.save!

      assert_empty view.check_distribution_conflicts!
    end

    def test_conflicting_distributions_nil_value_no_conflict
      view = @library_view
      view.repositories << Repository.find(katello_repositories(:rhel_7_no_arch))
      view.repositories << Repository.find(katello_repositories(:fedora_17_no_arch))
      view.save!

      assert_empty view.check_distribution_conflicts!
    end

    def test_duplicate_distributions
      view = @library_view
      duplicate_repo = Repository.find(katello_repositories(:fedora_17_x86_64_duplicate))

      view.repositories << duplicate_repo
      view.save!

      assert_includes view.duplicate_distributions, duplicate_repo
    end

    def test_distribution_conflicts
      view = @library_view
      conflicting_distribution = Repository.find(katello_repositories(:fedora_17_x86_64_duplicate))
      view.repositories << conflicting_distribution
      view.save!

      conflicts = view.distribution_conflicts
      assert_equal 2, conflicts.count
      conflicts.each do |c|
        assert_equal conflicting_distribution.distribution_version, c.distribution_version
        assert_equal conflicting_distribution.distribution_arch, c.distribution_arch
      end
      assert_includes conflicts, conflicting_distribution
    end

    def test_add_repository_from_other_org
      view = @library_view
      other_org = create(:katello_organization)
      other_org.create_library
      other_org.create_anonymous_provider
      other_org.save!
      library_view = create(:katello_content_view, :default => true,
                                                   :name => "Default Organization View",
                                                   :organization => other_org)

      ::Katello::ContentViewVersion.create! do |v|
        v.content_view = library_view
        v.major = 1
      end

      product = create(:katello_product, :organization => other_org, :provider => other_org.anonymous_provider)
      repo = create(:katello_repository, :product => product, :content_view_version =>
          other_org.default_content_view.versions.first)

      assert_raises(ActiveRecord::RecordInvalid) do
        view.repositories << repo
        view.save!
      end
    end

    def test_add_repository_from_other_view
      view = @library_view
      bad_repo =  Repository.find(katello_repositories(:fedora_17_x86_64_library_view_1))
      assert_raises(ActiveRecord::RecordInvalid) do
        view.repositories << bad_repo
        view.save!
      end
    end

    def test_content_view_version_publish_description
      version = @library_view.create_new_version("Awesome")
      assert_equal "Awesome", @library_view.versions.find(version.id).description
    end

    def test_search_name
      assert_equal @library_view, ContentView.search_for("name = \"#{@library_view.name}\"").first
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
  end
end
