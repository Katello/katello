require File.expand_path("repository_base", File.dirname(__FILE__))

module Katello
  class RepositoryCreateTest < RepositoryTestBase
    def setup
      super
      User.current = @admin
      @repo = build(:katello_repository, :fedora_17_el6,
                    :environment => @library,
                    :product => katello_products(:fedora),
                    :content_view_version => @library.default_content_view_version
                   )
    end

    def teardown
      @repo.destroy if @repo
    end

    def test_create
      assert @repo.save
      refute_empty Repository.where(:id => @repo.id)
    end

    def test_unique_repository_name_per_product_and_environment
      @repo.save
      @repo2 = build(:katello_repository,
                     :environment => @repo.environment,
                     :product => @repo.product,
                     :content_view_version => @repo.content_view_version,
                     :name => @repo.name,
                     :label => 'Another Label'
                    )

      refute @repo2.valid?
    end

    def test_docker_repository_docker_upstream_name_url
      @repo.unprotected = true
      @repo.content_type = 'docker'
      @repo.download_policy = nil
      @repo.docker_upstream_name = ""
      @repo.url = ""
      refute @repo.valid?
      @repo.url = "http://registry.com"
      refute @repo.valid?
      @repo.docker_upstream_name = "justin"
      assert @repo.valid?
      @repo.url = ""
      refute @repo.valid?
      @repo.url = "htp://boo.com"
      #bad url
      refute @repo.valid?
      @repo.url = nil
      @repo.docker_upstream_name = nil
      refute @repo.valid?
    end

    def test_docker_repository_in_content_view
      # verify: url and docker_upstream_name are not required for repositories
      # created as part of a content view
      library_repo = Repository.find(katello_repositories(:busybox).id)
      view_repo = build(:katello_repository,
                        :content_type => 'docker',
                        :name => 'view repo',
                        :label => 'view_repo',
                        :library_instance => library_repo,
                        :environment => library_repo.environment,
                        :product => library_repo.product,
                        :content_view_version => library_repo.content_view_version,
                        :unprotected => true,
                        :download_policy => nil,
                        :url => nil,
                        :docker_upstream_name => nil)
      assert view_repo.valid?
    end

    def test_docker_repository_docker_upstream_name_format
      @repo.unprotected = true
      @repo.content_type = 'docker'
      @repo.download_policy = nil
      valid = %w( valid
                  abc/valid
                  thisisareallylongbutstillvalidname
                  soisthis/thisisareallylongbutstillvalidname
                  single/slash
                  )
      valid << 'a' * 255
      valid.each do |name|
        @repo.docker_upstream_name = name
        assert(@repo.valid?, "container image name is valid '#{name}'")
      end
      invalid = %w( things\ with\ spaces
                    UPPERCASE Uppercase uppercasE Upper/case UPPER/case upper/Case
                    $ymbols $tuff.th@t.m!ght.h@ve.w%!rd.r#g#x.m*anings()
                    /startingslash trailingslash/
                    abcd/.-_
                    multiple/slash/es abc/def/invalid
                    )
      invalid << 'a' * 256
      invalid.each do |name|
        @repo.docker_upstream_name = name
        refute(@repo.valid?, "container image name is not valid '#{name}'")
      end
    end

    def test_docker_full_path
      full_path = @repo.full_path
      @repo.content_type = 'docker'
      @repo.download_policy = nil
      refute_equal full_path, @repo.full_path
      @repo.container_repository_name = "abc123"
      assert @repo.full_path =~ /abc123/
    end

    def test_download_policy
      @repo.content_type = 'yum'

      @repo.download_policy = 'immediate'
      assert @repo.valid?
      @repo.download_policy = 'on_demand'
      assert @repo.valid?

      @repo.download_policy = 'invalid'
      refute @repo.valid?
      assert @repo.errors.include?(:download_policy)

      @repo.content_type = 'puppet'
      refute @repo.valid?
      assert @repo.errors.include?(:download_policy)
    end

    def test_unique_repository_label_per_product_and_environment
      @repo.save
      @repo2 = build(:katello_repository,
                     :environment => @repo.environment,
                     :product => @repo.product,
                     :content_view_version => @repo.content_view_version,
                     :name => 'Another Name',
                     :label => @repo.label
                    )

      refute @repo2.valid?
    end

    def test_empty_errata
      @fedora_17_x86_64.errata.destroy_all
      filename = 'much-rpm.much-wow'

      erratum = @fedora_17_x86_64.errata.create! do |new_erratum|
        new_erratum.uuid = "foo"
        new_erratum.packages = [ErratumPackage.new(:filename => filename, :nvrea => 'foo', :name => 'foo')]
      end

      assert_includes @fedora_17_x86_64.empty_errata, erratum

      @fedora_17_x86_64.rpms.create! do |rpm|
        rpm.uuid = 'its the uuid that never ends oh wait it does'
        rpm.filename = filename
      end

      refute_includes @fedora_17_x86_64.empty_errata, erratum
    end

    def test_create_with_no_type
      @repo.content_type = ''
      assert_raises ActiveRecord::RecordInvalid do
        @repo.save!
      end
    end

    def test_content_type
      @repo.content_type = "puppet"
      @repo.download_policy = nil
      assert @repo.save
      assert_equal "puppet", Repository.find(@repo.id).content_type
    end

    def test_ostree_content_type
      @repo.content_type = "ostree"
      @repo.download_policy = nil
      assert @repo.save
      assert_equal "ostree", Repository.find(@repo.id).content_type
    end

    def test_docker_pulp_id
      # for docker repos, the pulp_id should be downcased
      @repo.name = 'docker_repo'
      @repo.pulp_id = 'PULP-ID'
      @repo.content_type = Repository::DOCKER_TYPE
      @repo.docker_upstream_name = "haha"
      @repo.unprotected = true
      @repo.download_policy = nil
      assert @repo.save
      assert @repo.pulp_id.ends_with?('pulp-id')
    end

    def test_docker_repo_unprotected
      @repo.name = 'docker_repo'
      @repo.pulp_id = 'PULP-ID'
      @repo.content_type = Repository::DOCKER_TYPE
      @repo.docker_upstream_name = "haha"
      @repo.unprotected = true
      @repo.download_policy = nil
      assert @repo.save
      @repo.unprotected = false
      refute @repo.save
    end

    def test_yum_type_pulp_id
      @repo.pulp_id = 'PULP-ID'
      @repo.content_type = Repository::YUM_TYPE
      assert @repo.save
      assert @repo.pulp_id.ends_with?('PULP-ID')
    end

    def test_puppet_type_pulp_id
      @repo.pulp_id = 'PULP-ID'
      @repo.content_type = Repository::PUPPET_TYPE
      @repo.download_policy = nil
      assert @repo.save
      assert @repo.pulp_id.ends_with?('PULP-ID')
    end

    def test_ostree_attribs
      @repo.content_type = Repository::OSTREE_TYPE
      @repo.url = "http://foo.com"
      @repo.download_policy = nil
      assert @repo.save
      @repo.url = ""
      refute @repo.save
    end

    def test_ostree_unprotected
      @repo.content_type = Repository::OSTREE_TYPE
      @repo.url = "http://foo.com"
      @repo.download_policy = nil
      @repo.unprotected = true
      refute @repo.save
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
  end

  class RepositorySearchTest < RepositoryTestBase
    def test_search_content_type
      repos = Repository.search_for("content_type = yum")
      assert_includes repos, @fedora_17_x86_64
      refute_includes repos, @puppet_forge
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

    def test_search_content_view_id
      repos = Repository.search_for("content_view_id = \"#{@fedora_17_x86_64.content_views.first.id}\"")
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

    def test_other_repos_with_same_content
      assert_includes @fedora_17_x86_64.other_repos_with_same_content, @fedora_17_x86_64_dev
    end

    def test_other_repos_with_same_product_and_content
      assert_includes @fedora_17_x86_64.other_repos_with_same_product_and_content, @fedora_17_x86_64_dev
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

      repo = build(:katello_repository,
                   :environment => @dev,
                   :content_view_version => @fedora_17_x86_64_dev.content_view_version,
                   :product => @fedora_17_x86_64_dev.product
                  )

      assert repo.valid?
      refute_nil repo.organization
      refute repo.promoted?
    end

    def test_get_clone
      assert_equal @fedora_17_dev_library_view, @fedora_17_library_library_view.get_clone(@dev)
    end

    def test_gpg_key_name
      @fedora_17_x86_64.gpg_key_name = @unassigned_gpg_key.name

      assert_equal @unassigned_gpg_key, @fedora_17_x86_64.gpg_key
    end

    def test_as_json
      assert_includes @fedora_17_x86_64.as_json, "gpg_key_name"
    end

    def test_units_for_removal_yum
      rpms = @fedora_17_x86_64.rpms.sample(2)
      rpm_ids = rpms.map(&:id).sort
      rpm_uuids = rpms.map(&:uuid).sort

      refute_empty rpms
      assert_equal rpm_ids, @fedora_17_x86_64.units_for_removal(rpm_ids).map(&:id).sort
      assert_equal rpm_ids, @fedora_17_x86_64.units_for_removal(rpm_ids.map(&:to_s)).map(&:id).sort
      assert_equal rpm_uuids, @fedora_17_x86_64.units_for_removal(rpm_uuids).map(&:uuid).sort
    end

    def test_units_for_removal_puppet
      puppet_modules = @puppet_forge.puppet_modules
      puppet_ids = puppet_modules.map(&:id).sort
      puppet_uuids = puppet_modules.map(&:uuid).sort

      refute_empty puppet_modules
      assert_equal puppet_ids, @puppet_forge.units_for_removal(puppet_ids).map(&:id).sort
      assert_equal puppet_ids, @puppet_forge.units_for_removal(puppet_ids.map(&:to_s)).map(&:id).sort
      assert_equal puppet_uuids, @puppet_forge.units_for_removal(puppet_uuids).map(&:uuid).sort
    end

    def test_packages_without_errata
      rpms = @fedora_17_x86_64.rpms
      errata_rpm = rpms[0]
      non_errata_rpm = rpms[1]
      @fedora_17_x86_64.errata.create! do |erratum|
        erratum.uuid = "foo"
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
        @redis.docker_manifests.create!(:name => str) do |manifest|
          manifest.uuid = str
        end
      end

      manifests = @redis.docker_manifests.sample(2).sort_by { |obj| obj.id }
      refute_empty manifests
      assert_equal manifests, @redis.units_for_removal(manifests.map(&:id)).sort_by { |obj| obj.id }
    end

    def test_units_for_removal_ostree
      ['one', 'two', 'three'].each do |str|
        @ostree_rhel7.ostree_branches.create!(:name => str) do |branch|
          branch.uuid = str
        end
      end

      branches = @ostree_rhel7.ostree_branches.sample(2).sort_by { |obj| obj.id }
      refute_empty branches
      assert_equal branches, @ostree_rhel7.units_for_removal(branches.map(&:id)).sort_by { |obj| obj.id }
    end

    def test_environmental_instances
      content_view = @fedora_17_dev_library_view.content_view
      assert_includes @fedora_17_dev_library_view.environmental_instances(content_view), @fedora_17_dev_library_view
      assert_includes @fedora_17_dev_library_view.environmental_instances(content_view), @fedora_17_library_library_view
    end

    def test_create_clone
      @fedora_17_dev_library_view.stubs(:checksum_type).returns(nil)
      clone = @fedora_17_dev_library_view.create_clone(:environment => @staging, :content_view => @library_dev_staging_view)
      assert clone.id
      assert Repository.in_environment(@staging).where(:library_instance_id => @fedora_17_x86_64.id).count > 0
    end

    def test_create_clone_preserve_type
      @fedora_17_library_library_view.stubs(:checksum_type).returns(nil)
      @fedora_17_library_library_view.content_type = 'file'
      @fedora_17_library_library_view.download_policy = nil
      @fedora_17_library_library_view.save!
      clone = @fedora_17_library_library_view.create_clone(:environment => @staging, :content_view => @library_dev_staging_view)
      assert clone.id
      assert_equal @fedora_17_library_library_view.content_type, clone.content_type
    end

    def test_clone_repo_path
      path = Repository.clone_repo_path(:repository => @fedora_17_x86_64,
                                        :version => @fedora_17_x86_64.content_view_version,
                                        :content_view => @fedora_17_x86_64.content_view
                                       )
      assert_equal "ACME_Corporation/content_views/org_default_label/1.0/fedora_17_label", path

      path = Repository.clone_repo_path(:repository => @fedora_17_x86_64,
                                        :environment => @fedora_17_x86_64.organization.library,
                                        :content_view => @fedora_17_x86_64.content_view
                                       )
      assert_equal "ACME_Corporation/library_default_view_library/fedora_17_label", path
    end

    def test_docker_clone_repo_path
      @repo = build(:katello_repository, :docker,
                    :environment => @library,
                    :product => katello_products(:fedora),
                    :content_view_version => @library.default_content_view_version
                   )
      path = Repository.clone_docker_repo_path(:repository => @repo,
                                               :version => @repo.content_view_version,
                                               :content_view => @repo.content_view
                                              )
      assert_equal "empty_organization-org_default_label-1.0-fedora_label-dockeruser_repo", path
      path = Repository.clone_docker_repo_path(:repository => @repo,
                                               :environment => @repo.organization.library,
                                               :content_view => @repo.content_view
                                              )
      assert_equal 'empty_organization-library_default_view_library-org_default_label-fedora_label-dockeruser_repo', path
    end

    def test_clone_repo_path_for_component
      # validate that clone repo path for a component view does not include the component view label
      library = KTEnvironment.find(katello_environments(:library).id)
      cv = ContentView.find(katello_content_views(:composite_view).id)
      cve = ContentViewEnvironment.where(:environment_id => library,
                                         :content_view_id => cv).first
      relative_path = Repository.clone_repo_path(repository: @fedora_17_x86_64,
                                                 environment: library,
                                                 content_view: cv)
      assert_equal "ACME_Corporation/#{cve.label}/fedora_17_label", relative_path

      # archive path
      version = stub(:version => 1)
      relative_path = Repository.clone_repo_path(repository: @fedora_17_x86_64,
                                                 version: version,
                                                 content_view: cv)
      assert_equal "ACME_Corporation/content_views/composite_view/1/fedora_17_label", relative_path
    end

    def new_custom_repo
      new_custom_repo = @fedora_17_x86_64.clone
      new_custom_repo.stubs(:label_not_changed).returns(true)
      new_custom_repo.name = "new_custom_repo"
      new_custom_repo.label = "new_custom_repo"
      new_custom_repo.pulp_id = "new_custom_repo"
      new_custom_repo
    end

    def test_nil_url_url
      new_repo = new_custom_repo
      new_repo.url = nil
      assert new_repo.save
      assert new_repo.persisted?
      assert_equal nil, new_repo.reload.url
      refute new_repo.url?
    end

    def test_blank_url_url
      new_repo = new_custom_repo

      original_url = new_repo.url
      new_repo.url = ""
      refute new_repo.save
      refute new_repo.errors.empty?
      assert_equal original_url, new_repo.reload.url
    end

    def test_nil_rhel_url
      rhel = Repository.find(katello_repositories(:rhel_6_x86_64).id)
      rhel.url = nil
      refute rhel.valid?
      refute rhel.save
      refute_empty rhel.errors
    end

    def test_node_syncable
      lib_yum_repo = Repository.find(katello_repositories(:rhel_6_x86_64).id)
      lib_puppet_repo = Repository.find(katello_repositories(:p_forge).id)
      lib_iso_repo = Repository.find(katello_repositories(:iso).id)
      lib_docker_repo = Repository.find(katello_repositories(:busybox).id)
      lib_ostree_repo = Repository.find(katello_repositories(:ostree_rhel7).id)

      assert lib_yum_repo.node_syncable?
      assert lib_puppet_repo.node_syncable?
      assert lib_iso_repo.node_syncable?
      assert lib_docker_repo.node_syncable?
      assert lib_ostree_repo.node_syncable?
    end

    def test_bad_checksum
      @fedora_17_x86_64.checksum_type = 'XOR'
      refute @fedora_17_x86_64.valid?
      refute @fedora_17_x86_64.save
    end

    def test_errata_filenames
      @rhel6 = Repository.find(katello_repositories(:rhel_6_x86_64).id)
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
      assert_equal @content_view_puppet_environment.capsule_download_policy(proxy), nil
      assert_equal @puppet_forge.capsule_download_policy(proxy), nil
      assert_not_nil @fedora_17_x86_64.download_policy
    end
  end

  class RepositoryApplicabilityTest < RepositoryTestBase
    def setup
      super
      @lib_host = FactoryGirl.create(:host, :with_content, :content_view => @fedora_17_x86_64.content_view,
                                     :lifecycle_environment =>  @fedora_17_x86_64.environment)

      @lib_host.content_facet.bound_repositories << @fedora_17_x86_64
      @lib_host.content_facet.save!

      @view_repo = Repository.find(katello_repositories(:fedora_17_x86_64_library_view_1).id)

      @view_host = FactoryGirl.create(:host, :with_content, :content_view => @fedora_17_x86_64.content_view,
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
