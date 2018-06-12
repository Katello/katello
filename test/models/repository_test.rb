require File.expand_path("repository_base", File.dirname(__FILE__))

module Katello
  class RepositoryCreateTest < RepositoryTestBase # rubocop:disable Metrics/ClassLength
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

    test_attributes :pid => '159f7296-55d2-4360-948f-c24e7d75b962'
    def test_create_with_name
      valid_name_list.each do |name|
        @repo.name = name
        assert @repo.valid?, "Validation failed for create with valid name: '#{name}' length: #{name.length})"
        assert_equal name, @repo.name
      end
    end

    test_attributes :pid => '3be1b3fa-0e17-416f-97f0-858709e6b1da'
    def test_create_with_label
      valid_label_list.each do |label|
        @repo.label = label
        assert @repo.valid?, "Validation failed for create with valid label: '#{label}' length: #{label.length})"
        assert_equal label, @repo.label
      end
    end

    test_attributes :pid => '7bac7f45-0fb3-4443-bb3b-cee72248ca5d'
    def test_create_with_content_type_yum
      @repo.content_type = 'yum'
      @repo.url = 'http://inecas.fedorapeople.org/fakerepos/zoo2/'
      assert_valid @repo
      assert_equal 'yum', @repo.content_type
    end

    test_attributes :pid => 'daa10ded-6de3-44b3-9707-9f0ac983d2ea'
    def test_create_with_content_type_puppet
      @repo.download_policy = nil
      @repo.content_type = 'puppet'
      @repo.url = 'http://davidd.fedorapeople.org/repos/random_puppet/'
      assert_valid @repo
      assert_equal 'puppet', @repo.content_type
    end

    test_attributes :pid => '1b17fe37-cdbf-4a79-9b0d-6813ea502754'
    def test_create_with_authenticated_yum_repo
      @repo.content_type = 'yum'
      valid_http_credentials_list(true).each do |credential|
        url = "http://#{credential[:login]}:#{credential[:pass]}@rplevka.fedorapeople.org/fakerepo01/"
        @repo.url = url
        assert @repo.valid?, "Validation failed for create with valid url: '#{url}'"
        assert_equal url, @repo.url
        assert_equal 'yum', @repo.content_type
      end
    end

    test_attributes :pid => '5e5479c4-904d-4892-bc43-6f81fa3813f8'
    def test_create_with_download_policy
      @repo.content_type = 'yum'
      @repo.url = 'http://inecas.fedorapeople.org/fakerepos/zoo2/'
      %w[on_demand background immediate].each do |download_policy|
        @repo.download_policy = download_policy
        assert @repo.valid?, "Validation failed for create with valid download_policy: '#{download_policy}'"
        assert_equal download_policy, @repo.download_policy
      end
    end

    test_attributes :pid => '8a70de9b-4663-4251-b91e-d3618ee7ef84'
    def test_create_immediate_update_to_on_demand
      new_download_policy = 'on_demand'
      @repo.download_policy = 'immediate'
      assert @repo.save
      @repo.download_policy = new_download_policy
      assert_valid @repo
      assert_equal new_download_policy, @repo.download_policy
    end

    test_attributes :pid => '9aaf53be-1127-4559-9faf-899888a52846'
    def test_create_immediate_update_to_background
      new_download_policy = 'background'
      @repo.download_policy = 'immediate'
      assert @repo.save
      @repo.download_policy = new_download_policy
      assert_valid @repo
      assert_equal new_download_policy, @repo.download_policy
    end

    test_attributes :pid => '589ff7bb-4251-4218-bb90-4e63c9baf702'
    def test_create_on_demand_update_to_immediate
      new_download_policy = 'immediate'
      @repo.download_policy = 'on_demand'
      assert @repo.save
      @repo.download_policy = new_download_policy
      assert_valid @repo
      assert_equal new_download_policy, @repo.download_policy
    end

    test_attributes :pid => '1d9888a0-c5b5-41a7-815d-47e936022a60'
    def test_create_on_demand_update_to_background
      new_download_policy = 'background'
      @repo.download_policy = 'on_demand'
      assert @repo.save
      @repo.download_policy = new_download_policy
      assert_valid @repo
      assert_equal new_download_policy, @repo.download_policy
    end

    test_attributes :pid => '169530a7-c5ce-4ca5-8cdd-15398e13e2af'
    def test_create_background_update_to_immediate
      new_download_policy = 'immediate'
      @repo.download_policy = 'background'
      assert @repo.save
      @repo.download_policy = new_download_policy
      assert_valid @repo
      assert_equal new_download_policy, @repo.download_policy
    end

    test_attributes :pid => '40a3e963-61ff-41c4-aa6c-d9a4a638af4a'
    def test_create_background_update_to_on_demand
      new_download_policy = 'on_demand'
      @repo.download_policy = 'background'
      assert @repo.save
      @repo.download_policy = new_download_policy
      assert_valid @repo
      assert_equal new_download_policy, @repo.download_policy
    end

    test_attributes :pid => 'af9e4f0f-d128-43d2-a680-0a62c7dab266'
    def test_positive_create_with_authenticated_puppet_repo
      @repo.download_policy = nil
      @repo.content_type = 'puppet'
      valid_http_credentials_list(true).each do |credential|
        url = "http://#{credential[:login]}:#{credential[:pass]}@rplevka.fedorapeople.org/fakepuppet01/"
        @repo.url = url
        assert @repo.valid?, "Validation failed for create with valid url: '#{url}'"
        assert_equal url, @repo.url
        assert_equal 'puppet', @repo.content_type
      end
    end

    test_attributes :pid => 'c3678878-758a-4501-a038-a59503fee453'
    def test_create_with_checksum_type
      %w[sha1 sha256].each do |checksum_type|
        @repo.checksum_type = checksum_type
        assert @repo.valid?, "Validation failed for create with valid checksum_type: '#{checksum_type}'"
        assert_equal checksum_type, @repo.checksum_type
      end
    end

    test_attributes :pid => '38f78733-6a72-4bf5-912a-cfc51658f80c'
    def test_positive_create_unprotected
      [true, false].each do |unprotected|
        @repo.unprotected = unprotected
        assert @repo.valid?, "Validation failed for create with valid unprotected: '#{unprotected}'"
        assert_equal unprotected, @repo.unprotected
      end
    end

    test_attributes :pid => '24947c92-3415-43df-add6-d6eb38afd8a3'
    def test_create_with_invalid_name
      invalid_name_list.each do |invalid_name|
        @repo.name = invalid_name
        refute @repo.valid?, "Validation passed for create with invalid name: '#{invalid_name}' length: #{invalid_name.length}"
        assert @repo.errors.key?(:name)
      end
    end

    test_attributes :pid => '0493dfc4-0043-4682-b339-ce61da7d48ae'
    def test_unique_repository_name_per_product_and_environment
      @repo.save!
      new_repo = build(:katello_repository,
                       :environment => @repo.environment,
                       :product => @repo.product,
                       :content_view_version => @repo.content_view_version,
                       :name => @repo.name,
                       :label => 'another_label'
                      )
      refute_valid new_repo
      assert new_repo.errors.key?(:name)
      assert_match 'has already been taken for this product.', new_repo.errors[:name][0]
    end

    test_attributes :pid => 'f646ae84-2660-41bd-9883-331285fa1c9a'
    def test_create_with_invalid_label
      @repo.label = RFauxFactory.gen_utf8
      refute_valid @repo
      assert @repo.errors.key?(:label)
      assert_match 'cannot contain characters other than ascii alpha numerals, \'_\', \'-\'.', @repo.errors[:label][0]
    end

    test_attributes :pid => '0bb9fc3f-d442-4437-b5d8-83024bc7ceab'
    def test_create_with_invalid_url
      @repo.content_type = 'yum'
      RFauxFactory.gen_strings(300).each do |value_type, invalid_url|
        @repo.url = invalid_url
        if [ :alpha, :numeric, :alphanumeric ].include?(value_type)
          refute_valid @repo
        else
          assert_raise URI::InvalidURIError do
            @repo.valid?
          end
        end
        assert @repo.errors.key?(:url)
        assert_match 'is invalid', @repo.errors[:url][0]
      end
    end

    test_attributes :pid => '2ffaa412-e5e5-4bec-afaa-9ea54315df49'
    def test_create_with_authenticated_url_with_special_characters
      # get the http_credentials without escaping and select only those of them that must be escaped
      invalid_credentials = valid_http_credentials_list(false).select { |cred| cred[:quote] }
      @repo.content_type = 'yum'
      invalid_credentials.each do |invalid_cred|
        url = "http://#{invalid_cred[:login]}:#{invalid_cred[:pass]}@rplevka.fedorapeople.org/fakerepo01/"
        @repo.url = url
        assert_raise URI::InvalidURIError do
          @repo.valid?
        end
        assert @repo.errors.key?(:url)
        assert_match 'is invalid', @repo.errors[:url][0]
      end
    end

    test_attributes :pid => '5aad4e9f-f7e1-497c-8e1f-55e07e38ee80'
    def test_create_with_authentication_url_too_long
      @repo.content_type = 'yum'
      invalid_http_credentials.each do |invalid_cred|
        url = "http://#{invalid_cred[:login]}:#{invalid_cred[:pass]}@rplevka.fedorapeople.org/fakerepo01/"
        @repo.url = url
        if [ :alpha, :numeric, :alphanumeric ].include?(invalid_cred[:string_type])
          refute_valid @repo
        else
          assert_raise URI::InvalidURIError do
            @repo.valid?
          end
        end
        assert @repo.errors.key?(:url)
        assert_match 'is too long (maximum is 1024 characters)', @repo.errors[:url][0]
      end
    end

    test_attributes :pid => '24d36e79-855e-4832-a136-30cbd144de44'
    def test_update_to_invalid_download_policy
      @repo.download_policy = 'background'
      assert @repo.save
      @repo.download_policy = 'invalid_download_policy'
      refute_valid @repo
      assert @repo.errors.key?(:download_policy)
      assert_match 'must be one of the following: immediate, on_demand, background', @repo.errors[:download_policy][0]
    end

    test_attributes :pid => '8a59cb31-164d-49df-b3c6-9b90634919ce'
    def test_create_non_yum_with_download_policy
      @repo.download_policy = 'on_demand'
      %w[puppet docker ostree].each do |content_type|
        @repo.content_type = content_type
        refute @repo.valid?, "Validation succeed for create with download_policy and non-yum repository: #{content_type}"
        assert @repo.errors.key?(:download_policy)
        assert_match 'cannot be set for non-yum repositories', @repo.errors[:download_policy][0]
      end
    end

    test_attributes :pid => 'c49a3c49-110d-4b74-ae14-5c9494a4541c'
    def test_create_with_invalid_checksum_type
      @repo.checksum_type = 'invalid checksum_type'
      refute_valid @repo
      assert @repo.errors.key?(:checksum_type)
      assert_match 'is not included in the list', @repo.errors[:checksum_type][0]
    end

    test_attributes :pid => '1b428129-7cf9-449b-9e3b-74360c5f9eca'
    def test_update_with_valid_name
      valid_name_list.each do |new_name|
        @fedora_17_x86_64.name = new_name
        assert @fedora_17_x86_64.valid?, "Validation failed for update with valid name: #{new_name} length: #{new_name.length}"
        assert_equal new_name, @fedora_17_x86_64.name
      end
    end

    test_attributes :pid => '205e6e59-33c6-4a58-9245-1cac3a4f550a'
    def test_update_checksum
      @repo.checksum_type = 'sha1'
      assert @repo.save
      @repo.checksum_type = 'sha256'
      assert_valid @repo
      assert_equal 'sha256', @repo.checksum_type
    end

    test_attributes :pid => '8fbc11f0-a5c5-498e-a314-87958dcd7832'
    def test_update_url
      new_url = 'http://new_repo_url.com'
      @fedora_17_x86_64.url = new_url
      assert_valid @fedora_17_x86_64
      assert_equal new_url, @fedora_17_x86_64.url
    end

    test_attributes :pid => 'c55d169a-8f11-4bf8-9913-b3d39fee75f0'
    def test_update_unprotected
      @fedora_17_x86_64.unprotected = true
      assert_valid @fedora_17_x86_64
      assert @fedora_17_x86_64.unprotected
    end

    test_attributes :pid => '6f2f41a4-d871-4b91-87b1-a5a401c4aa69'
    def test_update_with_invalid_name
      invalid_name_list.each do |invalid_name|
        @fedora_17_x86_64.name = invalid_name
        refute @fedora_17_x86_64.valid?, "Validation succeed for update with invalid name: #{invalid_name} length: #{invalid_name.length}"
        assert @fedora_17_x86_64.errors.key?(:name)
      end
    end

    test_attributes :pid => '828d85df-3c25-4a69-b6a2-401c6b82e4f3'
    def test_update_label
      repo = @fedora_17_x86_64
      repo.label = 'new_label'
      refute repo.valid?
      assert repo.errors.key?(:label)
      assert_match 'cannot be changed.', repo.errors[:label][0]
    end

    test_attributes :pid => '47530b1c-e964-402a-a633-c81583fb5b98'
    def test_update_auth_url_with_special_characters
      repo = @fedora_17_x86_64
      # get the http_credentials without escaping and select only those of them that must be escaped
      invalid_credentials = valid_http_credentials_list(false).select { |cred| cred[:quote] }
      invalid_credentials.each do |invalid_cred|
        url = "http://#{invalid_cred[:login]}:#{invalid_cred[:pass]}@rplevka.fedorapeople.org/fakerepo01/"
        repo.url = url
        assert_raise URI::InvalidURIError do
          repo.valid?
        end
        assert repo.errors.key?(:url)
        assert_match 'is invalid', repo.errors[:url][0]
      end
    end

    test_attributes :pid => 'cc00fbf4-d284-4404-88d9-ea0c0f03abe1'
    def test_update_auth_url_too_long
      repo = @fedora_17_x86_64
      invalid_http_credentials.each do |invalid_cred|
        url = "http://#{invalid_cred[:login]}:#{invalid_cred[:pass]}@rplevka.fedorapeople.org/fakerepo01/"
        repo.url = url
        if [ :alpha, :numeric, :alphanumeric ].include?(invalid_cred[:string_type])
          refute_valid repo
        else
          assert_raise URI::InvalidURIError do
            repo.valid?
          end
        end
        assert repo.errors.key?(:url)
        assert_match 'is too long (maximum is 1024 characters)', repo.errors[:url][0]
      end
    end

    test_attributes :pid => '29c2571a-b7fb-4ec7-b433-a1840758bcb0'
    def test_destroy
      repo = build(:katello_repository,
                   :environment => @library,
                   :product => katello_products(:ostree_product),
                   :content_view_version => @library.default_content_view_version,
                   :download_policy => 'on_demand',
                   :content_type => 'yum',
                   :url => 'http://rplevka.fedorapeople.org/fakerepo01/'
                  )
      repo.save!
      assert_difference('Repository.count', -1) do
        repo.delete
      end
    end

    def test_docker_repository_docker_upstream_name_url
      @repo.unprotected = true
      @repo.content_type = 'docker'
      @repo.download_policy = nil
      @repo.docker_upstream_name = ""
      @repo.url = nil
      assert @repo.valid?
      @repo.url = ""
      refute @repo.valid?
      @repo.url = "http://registry.com"
      refute @repo.valid?
      @repo.docker_upstream_name = "justin"
      assert @repo.valid?
      @repo.url = nil
      @repo.docker_upstream_name = ""
      assert @repo.valid?
      @repo.url = "htp://boo.com"
      #bad url
      refute @repo.valid?
      @repo.url = nil
      @repo.docker_upstream_name = nil
      assert @repo.valid?
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
                  multiple/slash/es abc/def/valid
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

    test_attributes :pid => 'c39bf33a-26f6-411b-8658-eab1bb40ef84'
    def test_create_with_invalid_download_policy
      @repo.content_type = 'yum'
      @repo.download_policy = 'invalid'
      refute @repo.valid?
      assert @repo.errors.include?(:download_policy)
      assert_match 'must be one of the following: immediate, on_demand, background', @repo.errors[:download_policy][0]
    end

    def test_compatible_download_policy
      @repo.content_type = 'yum'
      @repo.download_policy = 'on_demand'
      @repo.url = 'http://some.website/'
      assert @repo.valid?

      @repo.url = 'file://my.hard.drive/'
      refute @repo.valid?

      @repo.download_policy = 'background'
      refute @repo.valid?

      @repo.download_policy = 'immediate'
      assert @repo.valid?
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

    def test_archived_instance
      archived_repo = katello_repositories(:fedora_17_x86_64_dev_archive)
      env_repo = katello_repositories(:fedora_17_x86_64_dev)

      assert_equal archived_repo, env_repo.archived_instance
      assert_equal archived_repo, archived_repo.archived_instance

      assert_equal @fedora_17_x86_64, @fedora_17_x86_64.archived_instance
    end

    def test_content_type
      @repo.content_type = "puppet"
      @repo.download_policy = nil
      assert @repo.save
      assert_equal "puppet", Repository.find(@repo.id).content_type
    end

    test_attributes :pid => 'f3332dd3-1e6d-44e2-8f24-fae6fba2de8d'
    def test_ostree_content_type
      @repo.content_type = "ostree"
      @repo.download_policy = nil
      assert @repo.save
      assert_equal "ostree", Repository.find(@repo.id).content_type
    end

    test_attributes :pid => '4d9f1418-cc08-4c3c-a5dd-1d20fb9052a2'
    def test_ostree_content_type_update_name
      new_name = 'ostree new name'
      @ostree.name = new_name
      assert_valid @ostree
      assert_equal new_name, @ostree.name
    end

    test_attributes :pid => '6ba45475-a060-42a7-bc9e-ea2824a5476b'
    def test_ostree_content_type_update_url
      new_url = 'https://kojipkgs.fedoraproject.org/atomic/23/'
      @ostree.url = new_url
      assert_valid @ostree
      assert_equal new_url, @ostree.url
    end

    test_attributes :pid => '05db79ed-28c7-47fc-85f5-194a805d71ca'
    def test_ostree_content_type_destroy
      repo = build(:katello_repository,
                   :environment => @library,
                   :product => katello_products(:ostree_product),
                   :content_view_version => @library.default_content_view_version,
                   :download_policy => nil,
                   :content_type => 'ostree',
                   :url => 'https://kojipkgs.fedoraproject.org/atomic/23/',
                   :unprotected => false
                  )
      repo.save!
      assert_difference('Repository.count', -1) do
        repo.delete
      end
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

    def test_ostree_upstream_sync_policy
      @repo.content_type = Repository::OSTREE_TYPE
      @repo.url = "http://foo.com"
      @repo.download_policy = nil

      @repo.ostree_upstream_sync_policy = 'latest'
      assert @repo.valid?
      @repo.ostree_upstream_sync_policy = 'all'
      assert @repo.valid?
      @repo.ostree_upstream_sync_policy = 'boo'
      refute @repo.valid?
      assert @repo.errors.include?(:ostree_upstream_sync_policy)

      @repo.ostree_upstream_sync_policy = 'custom'
      refute @repo.valid?
      assert @repo.errors.include?(:ostree_upstream_sync_depth)

      @repo.ostree_upstream_sync_depth = 123
      assert @repo.valid?

      @repo.content_type = 'puppet'
      refute @repo.valid?
      assert @repo.errors.include?(:ostree_upstream_sync_policy)
    end

    def test_ostree_upstream_sync_policy_update
      @repo.content_type = Repository::OSTREE_TYPE
      @repo.url = "http://foo.com"
      @repo.download_policy = nil
      @repo.ostree_upstream_sync_policy = 'custom'
      @repo.ostree_upstream_sync_depth = 123
      assert @repo.save

      @repo.ostree_upstream_sync_policy = "all"
      assert @repo.save
      assert_nil @repo.ostree_upstream_sync_depth
    end

    def test_compute_ostree_upstream_sync_depth
      @repo.content_type = Repository::OSTREE_TYPE
      @repo.url = "http://foo.com"
      @repo.download_policy = nil

      @repo.ostree_upstream_sync_policy = 'all'
      assert_equal(-1, @repo.compute_ostree_upstream_sync_depth)

      @repo.ostree_upstream_sync_policy = 'latest'
      assert_equal 0, @repo.compute_ostree_upstream_sync_depth

      sync_depth = 124
      @repo.ostree_upstream_sync_policy = 'custom'
      @repo.ostree_upstream_sync_depth = sync_depth
      assert_equal sync_depth, @repo.compute_ostree_upstream_sync_depth
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
    end

    def test_yum_ignorable_content
      @repo.url = "http://foo.com"
      @repo.ignorable_content = nil
      assert @repo.valid?
      @repo.ignorable_content = ["srpm", "erratum"]
      assert @repo.valid?
      @repo.ignorable_content = ["boo"]
      refute @repo.valid?
      assert @repo.errors.include?(:ignorable_content)

      @repo.ignorable_content = ["srpm"]
      @repo.content_type = Repository::PUPPET_TYPE
      @repo.download_policy = nil
      refute @repo.valid?
      assert @repo.errors.include?(:ignorable_content)

      @repo.ignorable_content = nil
      assert @repo.valid?
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
      repo.label = "test_"
      repo.set_container_repository_name
      assert_equal 'empty_organization-puppet_product-test', repo.container_repository_name

      #replace more than 2 consecutive underscores.
      repo.label = 'te___st'
      repo.container_repository_name = nil
      repo.set_container_repository_name
      assert_equal 'empty_organization-puppet_product-te_st', repo.container_repository_name

      #replace more than 2 consecutive underscores with a single underscore iff it is not in the start or end of name.
      # Note that -_ is not allowed in the name either.
      repo.label = '_____tep______st_____'
      repo.container_repository_name = nil
      repo.set_container_repository_name
      assert_equal 'empty_organization-puppet_producttep_st', repo.container_repository_name

      #'-_' is not allowed in the name.
      repo.label = '-______test____'
      repo.container_repository_name = nil
      repo.set_container_repository_name
      assert_equal 'empty_organization-puppet_product-test', repo.container_repository_name
    end

    def test_container_repository_name_pattern
      repo = katello_repositories(:busybox)

      labels = [
        ['test', '<%= repository.label %>', 'test'],
        ['test', '<%= organization.label %> <%= repository.label %>', 'empty_organization_test'],
        ['test', ' <%= organization.label %>   <%= repository.label %> ', 'empty_organization_test']
      ]

      labels.each do |label, pattern, result|
        repo.label = label
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

    def test_search_redhat
      rhel_6 = katello_repositories(:rhel_6_x86_64)
      rhel_7 = katello_repositories(:rhel_7_x86_64)

      repos = Repository.search_for("redhat = true")
      assert_includes repos, rhel_6
      assert_includes repos, rhel_7
      refute_includes repos, @fedora_17_x86_64
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
        @redis.docker_manifests.create!(:digest => str) do |manifest|
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
      assert_nil new_repo.reload.url
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
      assert_nil @content_view_puppet_environment.capsule_download_policy(proxy)
      assert_nil @puppet_forge.capsule_download_policy(proxy)
      assert_not_nil @fedora_17_x86_64.download_policy
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

  class RepositoryAuditTest < RepositoryTestBase
    def setup
      super
      User.current = @admin
      @repo = build(:katello_repository, :fedora_17_el6,
                    :environment => @library,
                    :product => katello_products(:fedora),
                    :content_view_version => @library.default_content_view_version
                   )
    end

    def test_audit_on_repo_creation
      assert_difference 'Audit.count' do
        @repo.save!
      end
      recent_audit = @repo.audits.last
      assert_equal 'create', recent_audit.action
    end

    def test_audit_on_repo_destroy
      @repo.save!
      assert_difference 'Audit.count' do
        @repo.destroy
      end
      recent_audit = Audit.last
      assert_equal 'Katello::Repository', recent_audit.auditable_type
      assert_equal 'destroy', recent_audit.action
    end
  end
end
