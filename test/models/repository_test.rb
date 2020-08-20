require File.expand_path("repository_base", File.dirname(__FILE__))
require 'katello_test_helper'

module Katello
  class RepositoryCreateTest < RepositoryTestBase
    def setup
      super
      User.current = @admin
      @repo = katello_repositories(:rhel_6_x86_64)
      @rpm_one = katello_rpms(:one)
      @rpm_two = katello_rpms(:two)
      @errata_security = katello_errata(:security)
      @errata_bugfix = katello_errata(:bugfix)
    end

    def test_create
      assert @repo.save
      refute_empty Repository.where(:id => @repo.id)
    end

    def test_docker_full_path
      full_path = @repo.full_path
      @repo.root.content_type = 'docker'
      @repo.root.download_policy = nil
      refute_equal full_path, @repo.full_path
      @repo.container_repository_name = "abc123"
      assert @repo.full_path =~ /abc123/
    end

    def test_errata_counts
      source_repo = katello_repositories(:fedora_17_x86_64)
      source_repo.errata.destroy_all
      module_stream = katello_module_streams(:river)
      erratum = source_repo.errata.create! do |new_erratum|
        new_erratum.pulp_id = "foo"
        ep1 = ErratumPackage.new(:filename => @rpm_two.filename, :nvrea => 'foo', :name => 'foo')
        ep1.module_streams = [module_stream]
        ep2 = ErratumPackage.new(:filename => @rpm_one.filename, :nvrea => 'foo', :name => 'foo')
        new_erratum.packages = [ep1, ep2]
      end

      # We added 1 errata, 2 packages and 1 module stream to the source repo.
      assert_equal({erratum.id => 2}, ::Katello::Repository.errata_with_package_counts(source_repo))
      assert_equal({erratum.id => 1}, ::Katello::Repository.errata_with_module_stream_counts(source_repo))
    end

    def test_fetch_package_errata_to_keep
      @fedora_17_x86_64_dev = katello_repositories(:fedora_17_x86_64_dev)
      @fedora_17_x86_64_dev.errata.destroy_all

      source_repo = @fedora_17_x86_64_dev.library_instance
      source_repo.errata.destroy_all

      erratum = source_repo.errata.create! do |new_erratum|
        new_erratum.pulp_id = "foo"
        ep1 = ErratumPackage.new(:filename => @rpm_two.filename, :nvrea => 'foo', :name => 'foo')
        ep2 = ErratumPackage.new(:filename => @rpm_one.filename, :nvrea => 'foo', :name => 'foo')
        new_erratum.packages = [ep1, ep2]
      end

      @fedora_17_x86_64_dev.errata << erratum
      @fedora_17_x86_64_dev.save!
      @fedora_17_x86_64_dev.rpms.destroy_all
      assert_empty @fedora_17_x86_64_dev.fetch_package_errata_to_keep

      @fedora_17_x86_64_dev.rpms << @rpm_two
      @fedora_17_x86_64_dev.save!
      assert_empty @fedora_17_x86_64_dev.fetch_package_errata_to_keep

      @fedora_17_x86_64_dev.rpms << @rpm_one
      @fedora_17_x86_64_dev.save!
      assert_equal([erratum.id], @fedora_17_x86_64_dev.fetch_package_errata_to_keep)
    end

    def test_fetch_module_errata_to_filter
      @fedora_17_x86_64_dev = katello_repositories(:fedora_17_x86_64_dev)
      @fedora_17_x86_64_dev.errata.destroy_all

      source_repo = @fedora_17_x86_64_dev.library_instance
      source_repo.errata.destroy_all
      module_stream = katello_module_streams(:river)
      erratum = source_repo.errata.create! do |new_erratum|
        new_erratum.pulp_id = "foo"
        ep1 = ErratumPackage.new(:filename => @rpm_two.filename, :nvrea => 'foo', :name => 'foo')
        ep1.module_streams = [module_stream]
        new_erratum.packages = [ep1]
      end

      @fedora_17_x86_64_dev.errata << erratum
      @fedora_17_x86_64_dev.save!
      @fedora_17_x86_64_dev.module_streams.destroy_all
      assert_equal([erratum.id], @fedora_17_x86_64_dev.fetch_module_errata_to_filter)

      @fedora_17_x86_64_dev.module_streams << module_stream
      @fedora_17_x86_64_dev.save!

      assert_empty @fedora_17_x86_64_dev.fetch_module_errata_to_filter
    end

    def test_partial_errata
      @fedora_17_x86_64_dev = katello_repositories(:fedora_17_x86_64_dev)
      @fedora_17_x86_64_dev.errata.destroy_all

      source_repo = @fedora_17_x86_64_dev.library_instance
      source_repo.errata.destroy_all
      module_stream = katello_module_streams(:river)
      erratum = source_repo.errata.create! do |new_erratum|
        new_erratum.pulp_id = "foo"
        ep1 = ErratumPackage.new(:filename => @rpm_two.filename, :nvrea => 'foo', :name => 'foo')
        ep1.module_streams = [module_stream]
        new_erratum.packages = [ep1]
      end

      @fedora_17_x86_64_dev.errata << erratum
      @fedora_17_x86_64_dev.save!
      @fedora_17_x86_64_dev.module_streams.destroy_all
      @fedora_17_x86_64_dev.rpms.destroy_all

      assert_equal([erratum], @fedora_17_x86_64_dev.partial_errata)

      @fedora_17_x86_64_dev.rpms << @rpm_two
      @fedora_17_x86_64_dev.save!

      assert_equal([erratum], @fedora_17_x86_64_dev.partial_errata)

      @fedora_17_x86_64_dev.module_streams << module_stream
      @fedora_17_x86_64_dev.save!

      assert_empty @fedora_17_x86_64_dev.partial_errata
    end

    def test_partial_errata_package_counts
      @fedora_17_x86_64_dev = katello_repositories(:fedora_17_x86_64_dev)
      source_repo = @fedora_17_x86_64_dev.library_instance
      source_repo.errata.destroy_all
      @fedora_17_x86_64_dev.errata.destroy_all
      filename = 'much-rpm.much-wow'

      erratum = source_repo.errata.create! do |new_erratum|
        new_erratum.pulp_id = "foo"
        new_erratum.packages = [ErratumPackage.new(:filename => filename, :nvrea => 'foo', :name => 'foo')]
      end

      @fedora_17_x86_64_dev.errata << erratum
      @fedora_17_x86_64_dev.save!

      assert_includes @fedora_17_x86_64_dev.partial_errata, erratum

      rpm = source_repo.rpms.create! do |new_rpm|
        new_rpm.pulp_id = 'its the pulp_id that never ends oh wait it does'
        new_rpm.filename = filename
      end

      @fedora_17_x86_64_dev.rpms << rpm
      @fedora_17_x86_64_dev.save!

      refute_includes @fedora_17_x86_64_dev.partial_errata, erratum

      # Now lets test the case where the Errata in the library/source repo has 2 packages
      # While the dest repo only has Errata with one package
      # Expected Behavior -
      # "Errata should get deleted if its partial"
      # i.e only a subset of errata packages are present in the destination repo
      filename = 'much-rpm123.rpm'
      new_rpm = source_repo.rpms.create! do |another_rpm|
        another_rpm.pulp_id = 'its the NEW pulp_id that never ends oh wait it does'
        another_rpm.filename = filename
      end

      erratum.packages << [ErratumPackage.new(:filename => new_rpm.filename, :nvrea => 'bar', :name => 'bar')]
      erratum.save!

      assert_includes @fedora_17_x86_64_dev.partial_errata, erratum

      @fedora_17_x86_64_dev.rpms << new_rpm
      @fedora_17_x86_64_dev.save!
      refute_includes @fedora_17_x86_64_dev.partial_errata, erratum
    end

    def test_remove_partial_errata!
      @fedora_17_x86_64_dev = katello_repositories(:fedora_17_x86_64_dev)
      source_repo = @fedora_17_x86_64_dev.library_instance
      source_repo.errata.destroy_all
      @fedora_17_x86_64_dev.errata.destroy_all
      filename = 'much-rpm.much-wow'

      erratum = source_repo.errata.create! do |new_erratum|
        new_erratum.pulp_id = "foo"
        new_erratum.packages = [ErratumPackage.new(:filename => filename, :nvrea => 'foo', :name => 'foo')]
      end

      @fedora_17_x86_64_dev.errata << erratum
      @fedora_17_x86_64_dev.save!

      errata = @fedora_17_x86_64_dev.remove_partial_errata!
      assert_includes errata, erratum
      assert_not_includes @fedora_17_x86_64_dev.reload.errata, erratum
    end

    def test_fetch_module_streams_without_errata
      source_repo = katello_repositories(:fedora_17_x86_64)
      source_repo.module_streams.destroy_all
      module_stream_one = katello_module_streams(:one)
      module_stream_two = katello_module_streams(:two)
      source_repo.module_streams << module_stream_one
      source_repo.module_streams << module_stream_two
      source_repo.save!
      source_repo.errata.destroy_all

      source_repo.errata.create! do |new_erratum|
        new_erratum.pulp_id = "foo"
        ep1 = ErratumPackage.new(:filename => @rpm_two.filename, :nvrea => 'foo', :name => 'foo')
        ep1.module_streams = [module_stream_two]
        new_erratum.packages = [ep1]
      end
      assert_includes source_repo.module_streams, module_stream_one
      assert_includes source_repo.module_streams, module_stream_two
      assert_includes source_repo.module_streams_without_errata, module_stream_one
      assert_not_includes source_repo.module_streams_without_errata, module_stream_two
    end

    def test_archived_instance
      archived_repo = katello_repositories(:fedora_17_x86_64_dev_archive)
      env_repo = katello_repositories(:fedora_17_x86_64_dev)

      assert_equal archived_repo, env_repo.archived_instance
      assert_equal archived_repo, archived_repo.archived_instance

      assert_equal @fedora_17_x86_64, @fedora_17_x86_64.archived_instance
    end

    def test_docker_pulp_id
      # for docker repos, the pulp_id should be downcased
      repo = Repository.new(:root => katello_root_repositories(:busybox2_root),
                            :content_view_version => @repo.organization.default_content_view.versions.first,
                            :environment => @repo.organization.library,
                            :relative_path => "/asdfsafdaf")
      repo.pulp_id = 'PULP-ID'
      assert repo.save

      assert repo.pulp_id.ends_with?('pulp-id')
    end

    def test_master_link
      assert @puppet_forge.master?

      assert @fedora_17_x86_64.master?
      refute @fedora_17_x86_64.link?

      assert @fedora_17_x86_64_dev.link?
      refute @fedora_17_x86_64_dev.master?
      assert_equal @fedora_17_x86_64_dev.target_repository, katello_repositories(:fedora_17_x86_64_dev_archive)

      archive = katello_repositories(:fedora_17_x86_64_dev_archive)
      assert archive.master?
      refute archive.link?
    end

    def test_master_link_composite
      version = katello_content_view_versions(:composite_view_version_1)
      version_env_repo = katello_repositories(:rhel_6_x86_64_composite_view_version_1)
      version_archive_repo = version_env_repo.archived_instance

      assert version_env_repo.link?
      assert_equal version_archive_repo.target_repository, version_env_repo.target_repository

      assert version_archive_repo.link?
      assert_equal version_env_repo.content_view_version.components.first.repositories.where(:library_instance_id => version_env_repo.library_instance_id,
                                                                                             :environment_id => nil).first,
                   version_archive_repo.target_repository

      #now add a 2nd component to make the archive a "master", due to 'conflicting' repos
      version.components << katello_content_view_versions(:library_view_version_2)
      assert version_archive_repo.master?

      # composite environment repo should stay as a linked repo
      assert version_env_repo.link?

      version_archive_repo.rpms = [@rpm_one, @rpm_two]
      version_archive_repo.errata = [@errata_security, @errata_bugfix]
      version_archive_repo.save!

      SmartProxy.stubs(:pulp_master).returns(FactoryBot.create(:smart_proxy, :default_smart_proxy))
      version_env_repo.index_content
      assert_equal version_archive_repo.rpms.sort, version_env_repo.rpms.sort
      assert_equal version_archive_repo.errata.sort, version_env_repo.errata.sort
    end
  end

  class RepositoryGeneratedIdsTest < RepositoryTestBase
    def test_set_pulp_id_library_inst
      SecureRandom.expects(:uuid).returns('SECURE-UUID')
      @fedora_17_x86_64.pulp_id = nil
      @fedora_17_x86_64.set_pulp_id

      assert_equal 'SECURE-UUID', @fedora_17_x86_64.pulp_id
    end

    def test_set_pulp_id_archive
      archive_repo = katello_repositories(:fedora_17_x86_64_library_view_1)
      archive_repo.pulp_id = nil
      archive_repo.set_pulp_id

      assert_equal "#{archive_repo.organization.id}-published_library_view-v1_0-#{archive_repo.library_instance.pulp_id}", archive_repo.pulp_id
    end

    def test_set_pulp_id_cv_le
      @fedora_17_dev_library_view.pulp_id = nil
      @fedora_17_dev_library_view.set_pulp_id

      assert_equal "#{@fedora_17_dev_library_view.organization.id}-published_library_view-dev_label-#{@fedora_17_dev_library_view.library_instance.pulp_id}",
                   @fedora_17_dev_library_view.pulp_id
    end

    def test_set_pulp_id_max_chars
      SecureRandom.expects(:uuid).returns('SECURE-UUID')

      @fedora_17_dev_library_view.pulp_id = nil
      @fedora_17_dev_library_view.content_view.update_column(:label, 'a' * 120)
      @fedora_17_dev_library_view.environment.update_column(:label, 'b' * 120)
      @fedora_17_dev_library_view.set_pulp_id

      assert_equal 'SECURE-UUID', @fedora_17_dev_library_view.pulp_id
    end

    def test_set_pulp_id_no_overwrite
      id = @fedora_17_x86_64.pulp_id
      @fedora_17_x86_64.set_pulp_id
      assert_equal id, @fedora_17_x86_64.pulp_id
    end

    def test_set_pulp_id_save
      @fedora_17_x86_64.pulp_id = nil
      @fedora_17_x86_64.save!
      refute_nil @fedora_17_x86_64.pulp_id
    end

    def test_set_container_repository_name
      repo = katello_repositories(:busybox)
      repo.set_container_repository_name

      assert_equal 'empty_organization-puppet_product-busybox', repo.container_repository_name
    end

    def test_set_container_repository_name_cv
      repo = katello_repositories(:busybox_view1)
      repo.set_container_repository_name

      assert_equal 'empty_organization-published_library_view-1_0-puppet_product-busybox', repo.container_repository_name
    end

    def test_set_container_repository_name_special_chars
      repo = katello_repositories(:busybox)

      #name should not end in underscore
      repo.root.label = "test_"
      repo.set_container_repository_name
      assert_equal 'empty_organization-puppet_product-test', repo.container_repository_name

      #replace more than 2 consecutive underscores.
      repo.root.label = 'te___st'
      repo.container_repository_name = nil
      repo.set_container_repository_name
      assert_equal 'empty_organization-puppet_product-te_st', repo.container_repository_name

      #replace more than 2 consecutive underscores with a single underscore iff it is not in the start or end of name.
      # Note that -_ is not allowed in the name either.
      repo.root.label = '_____tep______st_____'
      repo.container_repository_name = nil
      repo.set_container_repository_name
      assert_equal 'empty_organization-puppet_producttep_st', repo.container_repository_name

      #'-_' is not allowed in the name.
      repo.root.label = '-______test____'
      repo.container_repository_name = nil
      repo.set_container_repository_name
      assert_equal 'empty_organization-puppet_product-test', repo.container_repository_name
    end

    def test_container_repository_name_pattern
      repo = katello_repositories(:busybox)

      labels = [
        ['test', '<%= repository.label %>', 'test'],
        ['test', '<%= organization.label %> <%= repository.label %>', 'empty_organization_test'],
        ['test', ' <%= organization.label %>   <%= repository.label %> ', 'empty_organization_test'],
        ['test', '', 'empty_organization-puppet_product-test']
      ]

      labels.each do |label, pattern, result|
        repo.root.label = label
        rendered = Repository.safe_render_container_name(repo, pattern)
        assert_equal rendered, result
      end
    end
  end

  class RepositorySearchTest < RepositoryTestBase
    def test_search_content_type
      repos = Repository.search_for("content_type = yum")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge
    end

    def test_search_name_fulltext
      repos = Repository.search_for(@fedora_17_x86_64.name)
      assert_includes repos, @fedora_17_x86_64
    end

    def test_search_name
      repos = Repository.search_for("name = \"#{@fedora_17_x86_64.name}\"")
      assert_includes repos, @fedora_17_x86_64
    end

    def test_search_product
      repos = Repository.search_for("product = \"#{@fedora_17_x86_64.product.name}\"")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge
    end

    def test_search_product_name
      repos = Repository.search_for("product_name = \"#{@fedora_17_x86_64.product.name}\"")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge
    end

    def test_search_product_id
      repos = Repository.search_for("product_id = \"#{@fedora_17_x86_64.product.id}\"")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge
    end

    def test_search_content_view_id
      repos = Repository.search_for("content_view_id = \"#{@fedora_17_x86_64.content_views.first.id}\"")
      assert_includes repos, @fedora_17_x86_64
    end

    def test_search_description
      repos = Repository.search_for("description = \"#{@fedora_17_x86_64.root.description}\"")
      assert_includes repos, @fedora_17_x86_64
    end

    def test_search_distribution_version
      repos = Repository.search_for("distribution_version = \"#{@fedora_17_x86_64.distribution_version}\"")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge

      empty = Repository.search_for("distribution_version = 100")
      assert_empty empty
    end

    def test_search_distribution_arch
      repos = Repository.search_for("distribution_arch = \"#{@fedora_17_x86_64.distribution_arch}\"")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge

      empty = Repository.search_for("distribution_arch = x_fake_arch")
      assert_empty empty
    end

    def test_search_distribution_family
      repos = Repository.search_for("distribution_family = \"#{@fedora_17_x86_64.distribution_family}\"")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge

      empty = Repository.search_for("distribution_family = not_a_family")
      assert_empty empty
    end

    def test_search_distribution_variant
      repos = Repository.search_for("distribution_variant = \"#{@fedora_17_x86_64.distribution_variant}\"")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge

      empty = Repository.search_for("distribution_variant = not_variant")
      assert_empty empty
    end

    def test_search_distribution_bootable
      repos = Repository.search_for("distribution_bootable = \"#{@fedora_17_x86_64.distribution_bootable}\"")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge
    end

    def test_search_redhat
      rhel_6 = katello_repositories(:rhel_6_x86_64)
      rhel_7 = katello_repositories(:rhel_7_x86_64)

      repos = Repository.search_for("redhat = true")
      assert_includes repos, rhel_6
      assert_includes repos, rhel_7
      refute_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge
    end

    def test_search_content_label
      content_id = 'somecontent-123'
      product = katello_products(:redhat)
      content = FactoryBot.create(:katello_content, cp_content_id: content_id, :organization_id => product.organization_id)
      FactoryBot.create(:katello_product_content, content: content, product: product)

      repo = katello_repositories(:fedora_17_x86_64)
      repo.root.update!(product: product, content_id: content_id)

      repos = Repository.search_for("content_label=\"#{content.label}\"")
      assert_includes repos, repo
    end
  end

  class RepositoryInstanceTest < RepositoryTestBase
    def setup
      super
      User.current = @admin
      @rhel6 = Repository.find(katello_repositories(:rhel_6_x86_64).id)
    end

    def test_product
      assert_equal @fedora, @fedora_17_x86_64.product
    end

    def test_environment
      assert_equal @library.id, @fedora_17_x86_64.environment.id
    end

    def test_organization
      assert_equal @acme_corporation.id, @fedora_17_x86_64.organization.id
    end

    def test_redhat?
      refute @fedora_17_x86_64.redhat?
    end

    def test_custom?
      assert @fedora_17_x86_64.custom?
    end

    def test_in_environment
      assert_includes Repository.in_environment(@library), @fedora_17_x86_64
    end

    def test_in_product
      assert_includes Repository.in_product(@fedora), @fedora_17_x86_64
    end

    def test_environment_id
      assert_equal @library.id, @fedora_17_x86_64.environment_id
    end

    def test_yum_gpg_key_url
      refute_nil @fedora_17_x86_64.yum_gpg_key_url
    end

    def test_clones
      assert_includes @fedora_17_x86_64.clones, @fedora_17_x86_64_dev
    end

    def test_group
      assert_includes @fedora_17_x86_64.group, @fedora_17_x86_64_dev
      assert_includes @fedora_17_x86_64.group, @fedora_17_x86_64
      assert_equal @fedora_17_x86_64.clones.count + 1, @fedora_17_x86_64.group.count
    end

    def test_cloned_in?
      assert @fedora_17_library_library_view.cloned_in?(@dev)
    end

    def test_promoted?
      assert @puppet_forge.promoted?

      repo = katello_repositories(:rhel_7_x86_64)

      refute repo.promoted?
    end

    def test_get_clone
      assert_equal @fedora_17_dev_library_view, @fedora_17_library_library_view.get_clone(@dev)
    end

    def test_units_for_removal_yum
      rpms = @fedora_17_x86_64.rpms.sample(2)
      rpm_ids = rpms.map(&:id).sort
      rpm_uuids = rpms.map(&:pulp_id).sort

      refute_empty rpms
      assert_equal rpm_ids, @fedora_17_x86_64.units_for_removal(rpm_ids).map(&:id).sort
      assert_equal rpm_ids, @fedora_17_x86_64.units_for_removal(rpm_ids.map(&:to_s)).map(&:id).sort
      assert_equal rpm_uuids, @fedora_17_x86_64.units_for_removal(rpm_uuids).map(&:pulp_id).sort
    end

    def test_units_for_removal_puppet
      puppet_modules = @puppet_forge.puppet_modules
      puppet_ids = puppet_modules.map(&:id).sort
      puppet_uuids = puppet_modules.map(&:pulp_id).sort

      refute_empty puppet_modules
      assert_equal puppet_ids, @puppet_forge.units_for_removal(puppet_ids).map(&:id).sort
      assert_equal puppet_ids, @puppet_forge.units_for_removal(puppet_ids.map(&:to_s)).map(&:id).sort
      assert_equal puppet_uuids, @puppet_forge.units_for_removal(puppet_uuids).map(&:pulp_id).sort
    end

    def test_packages_without_errata
      rpms = @fedora_17_x86_64.rpms
      errata_rpm = rpms[0]
      non_errata_rpm = rpms[1]
      @fedora_17_x86_64.errata.create! do |erratum|
        erratum.pulp_id = "foo"
        erratum.packages = [ErratumPackage.new(:filename => errata_rpm.filename, :nvrea => 'foo', :name => 'foo')]
      end

      filenames = @fedora_17_x86_64.packages_without_errata.map(&:filename)

      refute_empty filenames
      refute_includes filenames, errata_rpm.filename
      assert_includes filenames, non_errata_rpm.filename
    end

    def test_packages_without_errata_no_errata
      @fedora_17_x86_64.errata.destroy_all
      assert_equal @fedora_17_x86_64.rpms, @fedora_17_x86_64.packages_without_errata
    end

    def test_units_for_removal_docker
      ['one', 'two', 'three'].each do |str|
        @redis.docker_manifests.create!(:digest => str) do |manifest|
          manifest.pulp_id = str
        end
      end

      manifests = @redis.docker_manifests.sample(2).sort_by { |obj| obj.id }
      refute_empty manifests
      assert_equal manifests, @redis.units_for_removal(manifests.map(&:id)).sort_by { |obj| obj.id }
    end

    def test_units_for_removal_ostree
      ['one', 'two', 'three'].each do |str|
        @ostree.ostree_branches.create!(:name => str) do |branch|
          branch.pulp_id = str
        end
      end

      branches = @ostree.ostree_branches.sample(2).sort_by { |obj| obj.id }
      refute_empty branches
      assert_equal branches, @ostree.units_for_removal(branches.map(&:id)).sort_by { |obj| obj.id }
    end

    def test_environmental_instances
      content_view = @fedora_17_dev_library_view.content_view
      assert_includes @fedora_17_dev_library_view.environmental_instances(content_view), @fedora_17_dev_library_view
      assert_includes @fedora_17_dev_library_view.environmental_instances(content_view), @fedora_17_library_library_view
    end

    def test_clone_repo_path
      @fedora_17_x86_64.environment = nil
      assert_equal "#{@fedora_17_x86_64.organization.label}/content_views/org_default_label/1.0/fedora_17_label", @fedora_17_x86_64.generate_repo_path

      @fedora_17_x86_64.environment = @fedora_17_x86_64.organization.library
      assert_equal "#{@fedora_17_x86_64.organization.label}/library_default_view_library/fedora_17_label", @fedora_17_x86_64.generate_repo_path
    end

    def test_generate_content_path
      repo = katello_repositories(:rhel_6_x86_64)
      fixtures = [
        { input: '/content/rhel/x64', expected: '/content/rhel/x64' },
        { input: '/content/$releasever/$basearch', expected: '/content/6Server/x86_64' },
        { input: '/content/$releasever/f00-$basearch', expected: '/content/6Server/f00-x86_64' },
        { input: '/content/$basearch/foo/$releasever', expected: '/content/x86_64/foo/6Server' }
      ]

      fixtures.each do |fixture|
        repo.content.update!(content_url: fixture[:input])
        fail_message = "comparing #{fixture[:input]} - expected_result = #{fixture[:expected]}"
        assert_equal(fixture[:expected], repo.generate_content_path, fail_message)
      end
    end

    def test_docker_clone_repo_path
      @repo = build(:katello_repository, :docker,
                    :content_view_version => @fedora_17_x86_64.content_view_version,
                    :root => Katello::RootRepository.new(:label => 'dockeruser_repo', :product => @fedora_17_x86_64.product)
                   )

      assert_equal "empty_organization-org_default_label-1.0-fedora_label-dockeruser_repo", @repo.generate_docker_repo_path

      @repo.environment = @repo.organization.library
      assert_equal "empty_organization-library_default_view_library-org_default_label-#{@repo.product.label}-dockeruser_repo", @repo.generate_docker_repo_path
    end

    def test_generate_repo_path_for_component
      # validate that clone repo path for a component view does not include the component view label
      library = KTEnvironment.find(katello_environments(:library).id)
      cv = ContentView.find(katello_content_views(:composite_view).id)
      cve = ContentViewEnvironment.where(:environment_id => library,
                                         :content_view_id => cv).first
      @fedora_17_x86_64.content_view_version = cve.content_view_version

      assert_equal "#{cv.organization.label}/#{cve.label}/fedora_17_label", @fedora_17_x86_64.generate_repo_path

      @fedora_17_x86_64.content_view_version = katello_content_view_versions(:library_view_version_1)
      @fedora_17_x86_64.environment = nil

      assert_equal "#{@fedora_17_x86_64.organization.label}/content_views/#{@fedora_17_x86_64.content_view.label}/1.0/fedora_17_label", @fedora_17_x86_64.generate_repo_path
    end

    def new_custom_repo
      new_custom_repo = @fedora_17_x86_64.clone
      new_custom_repo.stubs(:label_not_changed).returns(true)
      new_custom_repo.name = "new_custom_repo"
      new_custom_repo.label = "new_custom_repo"
      new_custom_repo.pulp_id = "new_custom_repo"
      new_custom_repo
    end

    def test_node_syncable
      lib_yum_repo = katello_repositories(:rhel_6_x86_64)
      lib_puppet_repo = katello_repositories(:p_forge)
      lib_iso_repo = katello_repositories(:generic_file)
      lib_docker_repo = katello_repositories(:busybox)
      lib_ostree_repo = katello_repositories(:ostree)

      assert lib_yum_repo.node_syncable?
      assert lib_puppet_repo.node_syncable?
      assert lib_iso_repo.node_syncable?
      assert lib_docker_repo.node_syncable?
      assert lib_ostree_repo.node_syncable?
    end

    def test_errata_filenames
      @rhel6 = katello_repositories(:rhel_6_x86_64)
      @rhel6.errata.first.packages << katello_erratum_packages(:security_package)

      refute_empty @rhel6.errata_filenames
      assert_includes @rhel6.errata_filenames, @rhel6.errata.first.packages.first.filename
    end

    def test_with_errata
      errata = @rhel6.errata.first
      assert_includes Repository.with_errata([errata]), @rhel6
    end

    def test_capsule_download_policy
      proxy = SmartProxy.new(:download_policy => 'on_demand')
      assert_nil @content_view_puppet_environment.capsule_download_policy(proxy)
      assert_nil @puppet_forge.capsule_download_policy(proxy)
      assert_not_nil @fedora_17_x86_64.download_policy
    end

    def test_index_content_ordering
      repo_type = @rhel6.repository_type
      SmartProxy.stubs(:pulp_master).returns(FactoryBot.create(:smart_proxy, :default_smart_proxy))
      repo_types_hash = Hash[repo_type.content_types_to_index.map { |type| [type.model_class.content_type, type.priority] }]
      # {"rpm"=>1, "modulemd"=>2, "erratum"=>3, "package_group"=>99, "yum_repo_metadata_file"=>99, "srpm"=>99}

      # make sure rpms and module streams get indexed before errata
      assert repo_types_hash[::Katello::Rpm.content_type] < repo_types_hash[::Katello::Erratum.content_type]
      assert repo_types_hash[::Katello::ModuleStream.content_type] < repo_types_hash[::Katello::Erratum.content_type]
    end

    def test_in_content_view
      view = katello_content_views(:library_view)
      rhel7 = katello_repositories(:rhel_7_no_arch)
      assert @fedora_17_x86_64.in_content_view?(view)
      refute rhel7.in_content_view?(view)
    end
  end

  class RepositoryApplicabilityTest < RepositoryTestBase
    def setup
      super
      @lib_host = FactoryBot.create(:host, :with_content, :content_view => @fedora_17_x86_64.content_view,
                                     :lifecycle_environment =>  @fedora_17_x86_64.environment)

      @lib_host.content_facet.bound_repositories << @fedora_17_x86_64
      @lib_host.content_facet.save!

      @view_repo = Repository.find(katello_repositories(:fedora_17_x86_64_library_view_1).id)

      @view_host = FactoryBot.create(:host, :with_content, :content_view => @fedora_17_x86_64.content_view,
                                     :lifecycle_environment =>  @fedora_17_x86_64.environment)
      @view_host.content_facet.bound_repositories = [@view_repo]
      @view_host.content_facet.save!
    end

    def test_host_with_applicability
      assert_includes @fedora_17_x86_64.hosts_with_applicability, @lib_host
      assert_includes @fedora_17_x86_64.hosts_with_applicability, @view_host
    end
  end
end
