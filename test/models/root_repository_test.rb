require File.expand_path("repository_base", File.dirname(__FILE__))
require 'katello_test_helper'

module Katello
  class RootRepositoryCreateTest < RepositoryTestBase # rubocop:disable Metrics/ClassLength
    def setup
      super
      User.current = @admin
      @root = build(:katello_root_repository,
                    :product => katello_products(:fedora)
                   )
    end

    test_attributes :pid => '159f7296-55d2-4360-948f-c24e7d75b962'
    def test_create_with_name
      valid_name_list.each do |name|
        @root.name = name
        assert @root.valid?, "Validation failed for create with valid name: '#{name}' length: #{name.length})"
        assert_equal name, @root.name
      end
    end

    test_attributes :pid => '3be1b3fa-0e17-416f-97f0-858709e6b1da'
    def test_create_with_label
      valid_label_list.each do |label|
        @root.label = label
        assert @root.valid?, "Validation failed for create with valid label: '#{label}' length: #{label.length})"
        assert_equal label, @root.label
      end
    end

    test_attributes :pid => '7bac7f45-0fb3-4443-bb3b-cee72248ca5d'
    def test_create_with_content_type_yum
      @root.content_type = 'yum'
      @root.url = 'http://inecas.fedorapeople.org/fakerepos/zoo2/'
      assert_valid @root
      assert_equal 'yum', @root.content_type
    end

    test_attributes :pid => 'daa10ded-6de3-44b3-9707-9f0ac983d2ea'
    def test_create_with_content_type_puppet
      @root.download_policy = nil
      @root.content_type = 'puppet'
      @root.url = 'http://davidd.fedorapeople.org/repos/random_puppet/'
      assert_valid @root
      assert_equal 'puppet', @root.content_type
    end

    test_attributes :pid => '1b17fe37-cdbf-4a79-9b0d-6813ea502754'
    def test_create_with_authenticated_yum_repo
      @root.content_type = 'yum'
      valid_http_credentials_list(true).each do |credential|
        url = "http://#{credential[:login]}:#{credential[:pass]}@rplevka.fedorapeople.org/fakerepo01/"
        @root.url = url
        assert @root.valid?, "Validation failed for create with valid url: '#{url}'"
        assert_equal url, @root.url
        assert_equal 'yum', @root.content_type
      end
    end

    test_attributes :pid => '5e5479c4-904d-4892-bc43-6f81fa3813f8'
    def test_create_with_download_policy
      @root.content_type = 'yum'
      @root.url = 'http://inecas.fedorapeople.org/fakerepos/zoo2/'
      %w[on_demand background immediate].each do |download_policy|
        @root.download_policy = download_policy
        assert @root.valid?, "Validation failed for create with valid download_policy: '#{download_policy}'"
        assert_equal download_policy, @root.download_policy
      end
    end

    test_attributes :pid => '8a70de9b-4663-4251-b91e-d3618ee7ef84'
    def test_create_immediate_update_to_on_demand
      new_download_policy = 'on_demand'
      @root.download_policy = 'immediate'
      assert @root.save
      @root.download_policy = new_download_policy
      assert_valid @root
      assert_equal new_download_policy, @root.download_policy
    end

    test_attributes :pid => '9aaf53be-1127-4559-9faf-899888a52846'
    def test_create_immediate_update_to_background
      new_download_policy = 'background'
      @root.download_policy = 'immediate'
      assert @root.save
      @root.download_policy = new_download_policy
      assert_valid @root
      assert_equal new_download_policy, @root.download_policy
    end

    test_attributes :pid => '589ff7bb-4251-4218-bb90-4e63c9baf702'
    def test_create_on_demand_update_to_immediate
      new_download_policy = 'immediate'
      @root.download_policy = 'on_demand'
      assert @root.save
      @root.download_policy = new_download_policy
      assert_valid @root
      assert_equal new_download_policy, @root.download_policy
    end

    test_attributes :pid => '1d9888a0-c5b5-41a7-815d-47e936022a60'
    def test_create_on_demand_update_to_background
      new_download_policy = 'background'
      @root.download_policy = 'on_demand'
      assert @root.save
      @root.download_policy = new_download_policy
      assert_valid @root
      assert_equal new_download_policy, @root.download_policy
    end

    test_attributes :pid => '169530a7-c5ce-4ca5-8cdd-15398e13e2af'
    def test_create_background_update_to_immediate
      new_download_policy = 'immediate'
      @root.download_policy = 'background'
      assert @root.save
      @root.download_policy = new_download_policy
      assert_valid @root
      assert_equal new_download_policy, @root.download_policy
    end

    test_attributes :pid => '40a3e963-61ff-41c4-aa6c-d9a4a638af4a'
    def test_create_background_update_to_on_demand
      new_download_policy = 'on_demand'
      @root.download_policy = 'background'
      assert @root.save
      @root.download_policy = new_download_policy
      assert_valid @root
      assert_equal new_download_policy, @root.download_policy
    end

    test_attributes :pid => 'af9e4f0f-d128-43d2-a680-0a62c7dab266'
    def test_positive_create_with_authenticated_puppet_repo
      @root.download_policy = nil
      @root.content_type = 'puppet'
      valid_http_credentials_list(true).each do |credential|
        url = "http://#{credential[:login]}:#{credential[:pass]}@rplevka.fedorapeople.org/fakepuppet01/"
        @root.url = url
        assert @root.valid?, "Validation failed for create with valid url: '#{url}'"
        assert_equal url, @root.url
        assert_equal 'puppet', @root.content_type
      end
    end

    test_attributes :pid => 'c3678878-758a-4501-a038-a59503fee453'
    def test_create_with_checksum_type
      %w[sha1 sha256].each do |checksum_type|
        @root.checksum_type = checksum_type
        @root.download_policy = 'immediate'
        assert @root.valid?, "Validation failed for create with valid checksum_type: '#{checksum_type}'"
        assert_equal checksum_type, @root.checksum_type
      end
    end

    def test_create_with_on_demand_checksum
      %w[sha1 sha256].each do |checksum_type|
        @root.checksum_type = checksum_type
        refute @root.valid?, "Validation failed for create with valid checksum_type: '#{checksum_type}'"
        assert @root.errors.key?(:checksum_type)
      end
    end

    test_attributes :pid => '38f78733-6a72-4bf5-912a-cfc51658f80c'
    def test_positive_create_unprotected
      [true, false].each do |unprotected|
        @root.unprotected = unprotected
        assert @root.valid?, "Validation failed for create with valid unprotected: '#{unprotected}'"
        assert_equal unprotected, @root.unprotected
      end
    end

    test_attributes :pid => '24947c92-3415-43df-add6-d6eb38afd8a3'
    def test_create_with_invalid_name
      invalid_name_list.each do |invalid_name|
        @root.name = invalid_name
        refute @root.valid?, "Validation passed for create with invalid name: '#{invalid_name}' length: #{invalid_name.length}"
        assert @root.errors.key?(:name)
      end
    end

    test_attributes :pid => '0493dfc4-0043-4682-b339-ce61da7d48ae'
    def test_unique_repository_name_per_product
      @root.save!
      new_repo = build(:katello_root_repository,
                       :product => @root.product,
                       :name => @root.name,
                       :label => 'another_label'
                      )

      refute_valid new_repo
      assert new_repo.errors.key?(:name)
      assert_match 'has already been taken for this product.', new_repo.errors[:name][0]
    end

    test_attributes :pid => 'f646ae84-2660-41bd-9883-331285fa1c9a'
    def test_create_with_invalid_label
      @root.label = RFauxFactory.gen_utf8
      refute_valid @root
      assert @root.errors.key?(:label)
      assert_match 'cannot contain characters other than ascii alpha numerals, \'_\', \'-\'.', @root.errors[:label][0]
    end

    test_attributes :pid => '0bb9fc3f-d442-4437-b5d8-83024bc7ceab'
    def test_create_with_invalid_url
      @root.content_type = 'yum'
      RFauxFactory.gen_strings(300).each do |value_type, invalid_url|
        @root.url = invalid_url
        if [ :alpha, :numeric, :alphanumeric ].include?(value_type)
          refute_valid @root
        else
          assert_raise URI::InvalidURIError do
            @root.valid?
          end
        end
        assert @root.errors.key?(:url)
        assert_match 'is invalid', @root.errors[:url][0]
      end
    end

    test_attributes :pid => '2ffaa412-e5e5-4bec-afaa-9ea54315df49'
    def test_create_with_authenticated_url_with_special_characters
      # get the http_credentials without escaping and select only those of them that must be escaped
      invalid_credentials = valid_http_credentials_list(false).select { |cred| cred[:quote] }
      @root.content_type = 'yum'
      invalid_credentials.each do |invalid_cred|
        url = "http://#{invalid_cred[:login]}:#{invalid_cred[:pass]}@rplevka.fedorapeople.org/fakerepo01/"
        @root.url = url
        assert_raise URI::InvalidURIError do
          @root.valid?
        end
        assert @root.errors.key?(:url)
        assert_match 'is invalid', @root.errors[:url][0]
      end
    end

    test_attributes :pid => '5aad4e9f-f7e1-497c-8e1f-55e07e38ee80'
    def test_create_with_authentication_url_too_long
      @root.content_type = 'yum'
      invalid_http_credentials.each do |invalid_cred|
        url = "http://#{invalid_cred[:login]}:#{invalid_cred[:pass]}@rplevka.fedorapeople.org/fakerepo01/"
        @root.url = url
        if [ :alpha, :numeric, :alphanumeric ].include?(invalid_cred[:string_type])
          refute_valid @root
        else
          assert_raise URI::InvalidURIError do
            @root.valid?
          end
        end
        assert @root.errors.key?(:url)
        assert_match 'is too long (maximum is 1024 characters)', @root.errors[:url][0]
      end
    end

    test_attributes :pid => '24d36e79-855e-4832-a136-30cbd144de44'
    def test_update_to_invalid_download_policy
      @root.download_policy = 'background'
      assert @root.save
      @root.download_policy = 'invalid_download_policy'
      refute_valid @root
      assert @root.errors.key?(:download_policy)
      assert_match 'must be one of the following: immediate, on_demand, background', @root.errors[:download_policy][0]
    end

    test_attributes :pid => '8a59cb31-164d-49df-b3c6-9b90634919ce'
    def test_create_non_yum_with_download_policy
      @root.download_policy = 'on_demand'
      %w[puppet docker ostree].each do |content_type|
        @root.content_type = content_type
        refute @root.valid?, "Validation succeed for create with download_policy and non-yum repository: #{content_type}"
        assert @root.errors.key?(:download_policy)
        assert_match(/Cannot set attribute.*#{content_type}.*/, @root.errors[:download_policy][0])
      end
    end

    test_attributes :pid => 'c49a3c49-110d-4b74-ae14-5c9494a4541c'
    def test_create_with_invalid_checksum_type
      @root.checksum_type = 'invalid checksum_type'
      @root.download_policy = 'immediate'
      refute_valid @root
      assert @root.errors.key?(:checksum_type)
      assert_match 'is not included in the list', @root.errors[:checksum_type][0]
    end

    def test_create_with_duplicate_name_different_product
      fedora = katello_products(:fedora)
      redhat = katello_products(:redhat)

      RootRepository.create!(:product => fedora, :name => :foo, :content_type => :yum, :download_policy => :immediate, :url => 'http://foo/')
      RootRepository.create!(:product => redhat, :name => :foo, :content_type => :yum, :download_policy => :immediate, :url => 'http://foo/')

      assert_raises(ActiveRecord::RecordInvalid) do
        RootRepository.create!(:product => fedora, :name => :foo, :content_type => :yum, :download_policy => :immediate, :url => 'http://foo/')
      end
    end

    def test_invalid_upstream_password_update
      @root.upstream_password = "password"
      refute @root.save
    end

    def test_invalid_upstream_username_update
      @root.upstream_password = "username"
      refute @root.save
    end

    def test_valid_upstream_authorization
      ENV['ENCRYPTION_KEY'] = "25d224dd383e92a7e0c82b8bf7c985e9"

      @root.upstream_password = "password"
      @root.upstream_username = "username"
      assert @root.save
      assert_equal "password", @root.upstream_password
      assert_equal "[redacted]", @root.audits.last.audited_changes["upstream_password"]
    end

    def test_invalid_upstream_authorization
      rhel_6 = katello_root_repositories(:rhel_6_x86_64_root)
      rhel_6.upstream_password = "password"
      rhel_6.upstream_username = "username"
      refute rhel_6.save
    end

    test_attributes :pid => '1b428129-7cf9-449b-9e3b-74360c5f9eca'
    def test_update_with_valid_name
      valid_name_list.each do |new_name|
        @fedora_root.name = new_name
        assert @fedora_root.valid?
      end
    end

    test_attributes :pid => '205e6e59-33c6-4a58-9245-1cac3a4f550a'
    def test_update_checksum
      @root.download_policy = 'immediate'
      @root.checksum_type = 'sha1'
      assert @root.save
      @root.checksum_type = 'sha256'
      assert_valid @root
      assert_equal 'sha256', @root.checksum_type
    end

    test_attributes :pid => '8fbc11f0-a5c5-498e-a314-87958dcd7832'
    def test_update_url
      new_url = 'http://new_repo_url.com'
      @fedora_root.url = new_url
      assert_valid @fedora_root
      assert_equal new_url, @fedora_root.url
    end

    test_attributes :pid => 'c55d169a-8f11-4bf8-9913-b3d39fee75f0'
    def test_update_unprotected
      @fedora_root.unprotected = true
      assert_valid @fedora_root
      assert @fedora_root.unprotected
    end

    test_attributes :pid => '6f2f41a4-d871-4b91-87b1-a5a401c4aa69'
    def test_update_with_invalid_name
      invalid_name_list.each do |invalid_name|
        @fedora_root.name = invalid_name
        refute @fedora_root.valid?, "Validation succeed for update with invalid name: #{invalid_name} length: #{invalid_name.length}"
        assert @fedora_root.errors.key?(:name)
      end
    end

    test_attributes :pid => '828d85df-3c25-4a69-b6a2-401c6b82e4f3'
    def test_update_label
      repo = @fedora_root
      repo.label = 'new_label'
      refute repo.valid?
      assert repo.errors.key?(:label)
      assert_match 'cannot be changed.', repo.errors[:label][0]
    end

    test_attributes :pid => '47530b1c-e964-402a-a633-c81583fb5b98'
    def test_update_auth_url_with_special_characters
      repo = @fedora_root
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
      repo = @fedora_root
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

    def test_pulp_update_needed_with_docker_white_tags?
      refute @docker_root.pulp_update_needed?
      @docker_root.docker_tags_whitelist = ['3.7']
      @docker_root.save!
      assert @docker_root.pulp_update_needed?
    end

    def test_pulp_update_needed_with_upstream_auth_change?
      repo = katello_root_repositories(:fedora_17_x86_64_root)
      refute repo.pulp_update_needed?
      repo.upstream_username = 'amazing'
      repo.upstream_password = 'super-secret'
      repo.save!
      assert repo.pulp_update_needed?

      repo = katello_root_repositories(:fedora_17_x86_64_root).reload
      refute repo.pulp_update_needed?
      repo.upstream_password = 'amazing'
      repo.save!
      assert repo.pulp_update_needed?
    end

    def test_docker_repository_docker_upstream_name_url
      @root.unprotected = true
      @root.content_type = 'docker'
      @root.download_policy = nil
      @root.docker_upstream_name = ""
      @root.url = nil
      assert @root.valid?
      @root.url = ""
      refute @root.valid?
      @root.url = "http://registry.com"
      refute @root.valid?
      @root.docker_upstream_name = "justin"
      assert @root.valid?
      @root.url = nil
      @root.docker_upstream_name = ""
      assert @root.valid?
      @root.url = "htp://boo.com"
      #bad url
      refute @root.valid?
      @root.url = nil
      @root.docker_upstream_name = nil
      assert @root.valid?
    end

    test_attributes :pid => '7967e6b5-c206-4ad0-bcf5-64a7ce85233b'
    def test_docker_repository_update_name
      @root = katello_root_repositories(:busybox_root)
      valid_name_list.each do |name|
        @root.name = name
        assert @root.valid?
      end
    end

    test_attributes :pid => 'c39bf33a-26f6-411b-8658-eab1bb40ef84'
    def test_create_with_invalid_download_policy
      @root.content_type = 'yum'
      @root.download_policy = 'invalid'
      refute @root.valid?
      assert_includes @root.errors, :download_policy
      assert_match 'must be one of the following: immediate, on_demand, background', @root.errors[:download_policy][0]
    end

    def test_compatible_download_policy
      @root.content_type = 'yum'
      @root.download_policy = 'on_demand'
      @root.url = 'http://some.website/'
      assert @root.valid?

      @root.url = 'file://my.hard.drive/'
      refute @root.valid?

      @root.download_policy = 'background'
      refute @root.valid?

      @root.download_policy = 'immediate'
      assert @root.valid?
    end

    def test_unique_root_repository_label
      @root.save
      @root2 = build(:katello_root_repository,
                     :product => @root.product,
                     :name => 'Another Name',
                     :label => @root.label
                    )

      refute @root2.valid?
    end

    def test_create_with_no_type
      @root.content_type = ''
      assert_raises ActiveRecord::RecordInvalid do
        @root.save!
      end
    end

    test_attributes :pid => 'f3332dd3-1e6d-44e2-8f24-fae6fba2de8d'
    def test_ostree_content_type
      @root.content_type = "ostree"
      @root.download_policy = nil
      assert @root.valid?
    end

    test_attributes :pid => '4d9f1418-cc08-4c3c-a5dd-1d20fb9052a2'
    def test_ostree_content_type_update_name
      new_name = 'ostree new name'
      @ostree_root.name = new_name
      assert_valid @ostree_root
      assert_equal new_name, @ostree_root.name
    end

    test_attributes :pid => '6ba45475-a060-42a7-bc9e-ea2824a5476b'
    def test_ostree_content_type_update_url
      new_url = 'https://kojipkgs.fedoraproject.org/atomic/23/'
      @ostree_root.url = new_url
      assert_valid @ostree_root
      assert_equal new_url, @ostree_root.url
    end

    def test_docker_repo_unprotected
      @root.name = 'docker_repo'
      @root.content_type = Repository::DOCKER_TYPE
      @root.docker_upstream_name = "haha"
      @root.unprotected = true
      @root.download_policy = nil
      assert @root.valid?
      @root.unprotected = false
      refute @root.valid?
    end

    def test_ostree_attribs
      @root.content_type = Repository::OSTREE_TYPE
      @root.url = "http://foo.com"
      @root.download_policy = nil
      assert @root.valid?
      @root.url = ""
      refute @root.valid?
    end

    def test_ostree_unprotected
      @root.content_type = Repository::OSTREE_TYPE
      @root.url = "http://foo.com"
      @root.download_policy = nil
      @root.unprotected = true
      refute @root.valid?
    end

    def test_ostree_upstream_sync_policy
      @root.content_type = Repository::OSTREE_TYPE
      @root.url = "http://foo.com"
      @root.download_policy = nil

      @root.ostree_upstream_sync_policy = 'latest'
      assert @root.valid?
      @root.ostree_upstream_sync_policy = 'all'
      assert @root.valid?
      @root.ostree_upstream_sync_policy = 'boo'
      refute @root.valid?
      assert_includes @root.errors, :ostree_upstream_sync_policy

      @root.ostree_upstream_sync_policy = 'custom'
      refute @root.valid?
      assert_includes @root.errors, :ostree_upstream_sync_depth

      @root.ostree_upstream_sync_depth = 123
      assert @root.valid?

      @root.content_type = 'puppet'
      refute @root.valid?
      assert_includes @root.errors, :ostree_upstream_sync_policy
    end

    def test_ostree_upstream_sync_policy_update
      @root.content_type = Repository::OSTREE_TYPE
      @root.url = "http://foo.com"
      @root.download_policy = nil
      @root.ostree_upstream_sync_policy = 'custom'
      @root.ostree_upstream_sync_depth = 123

      assert @root.valid?
      assert @root.save

      @root.ostree_upstream_sync_policy = "all"
      assert @root.valid?
      assert_nil @root.ostree_upstream_sync_depth
    end

    def test_compute_ostree_upstream_sync_depth
      @root.content_type = Repository::OSTREE_TYPE
      @root.url = "http://foo.com"
      @root.download_policy = nil

      @root.ostree_upstream_sync_policy = 'all'
      assert_equal(-1, @root.compute_ostree_upstream_sync_depth)

      @root.ostree_upstream_sync_policy = 'latest'
      assert_equal 0, @root.compute_ostree_upstream_sync_depth

      sync_depth = 124
      @root.ostree_upstream_sync_policy = 'custom'
      @root.ostree_upstream_sync_depth = sync_depth
      assert_equal sync_depth, @root.compute_ostree_upstream_sync_depth
    end

    def test_yum_ignorable_content
      @root.url = "http://foo.com"
      @root.ignorable_content = nil
      assert @root.valid?
      @root.ignorable_content = ["srpm", "erratum"]

      assert @root.valid?
      @root.ignorable_content = ["boo"]
      refute @root.valid?
      assert_includes @root.errors, :ignorable_content

      @root.ignorable_content = ["srpm"]
      @root.content_type = Repository::PUPPET_TYPE
      @root.download_policy = nil
      refute @root.valid?
      assert_includes @root.errors, :ignorable_content

      @root.ignorable_content = nil
      assert @root.valid?
    end

    def test_docker_white_tags
      @docker_root.url = "http://foo.com"
      @docker_root.docker_tags_whitelist = nil
      assert @root.valid?
      @docker_root.docker_tags_whitelist = ["latest", "1.1"]
      assert @docker_root.valid?

      @root.content_type = Repository::OSTREE_TYPE
      @root.docker_tags_whitelist = ["boo"]
      refute @root.valid?
    end
  end

  class RootRepositoryInstanceTest < RepositoryTestBase
    def setup
      super
      User.current = @admin
    end

    def test_nil_url_url
      new_repo = Katello::RootRepository.new(@fedora_root.attributes.slice('product_id', 'content_type', 'download_policy'))
      new_repo.product = @fedora_root.product
      new_repo.name = "new_custom_repo"
      new_repo.label = "new_custom_repo"
      new_repo.url = nil

      assert new_repo.valid?
    end

    def test_nil_rhel_url
      rhel = katello_root_repositories(:rhel_6_x86_64_root)
      rhel.url = nil
      refute rhel.valid?
    end

    def test_bad_checksum
      @fedora_root.checksum_type = 'XOR'
      refute @fedora_root.valid?
    end

    def test_capsule_download_policy
      proxy = SmartProxy.new(:download_policy => 'on_demand')
      assert_nil @content_view_puppet_environment.capsule_download_policy(proxy)
      assert_nil @puppet_forge.capsule_download_policy(proxy)
      assert_not_nil @fedora_17_x86_64.download_policy
    end

    def test_pulp_update_needed?
      refute @fedora_root.pulp_update_needed?

      @fedora_root.url = 'https://www.google.com'
      @fedora_root.save!
      assert @fedora_root.pulp_update_needed?

      @fedora_root.stubs(:redhat?).returns(true)

      @fedora_root.url = 'https://www.yahoo.com'
      @fedora_root.save!
      assert @fedora_root.pulp_update_needed?
    end

    def test_pulp_update_needed_with_upstream_name_passwd?
      refute @fedora_root.pulp_update_needed?
      @fedora_root.upstream_username = 'amazing'
      @fedora_root.upstream_password = 'super-secret'
      @fedora_root.save!
      assert @fedora_root.pulp_update_needed?

      @fedora_root = @fedora_root.reload
      refute @fedora_root.pulp_update_needed?
      @fedora_root.upstream_password = 'amazing'
      @fedora_root.save!
      assert @fedora_root.pulp_update_needed?
    end

    def test_ostree_pulp_update_needed?
      refute @ostree_root.pulp_update_needed?
      @ostree_root.ostree_upstream_sync_policy = "custom"
      @ostree_root.ostree_upstream_sync_depth = 10
      @ostree_root.save!
      assert @ostree_root.pulp_update_needed?

      @ostree_root.reload
      refute @ostree_root.pulp_update_needed?
      @ostree_root.ostree_upstream_sync_depth = 5000
      @ostree_root.save!
      assert @ostree_root.pulp_update_needed?
    end

    def test_pulp_update_needed_with_ssl?
      cert = GpgKey.find(katello_gpg_keys(:fedora_cert).id)
      refute @fedora_root.pulp_update_needed?
      @fedora_root.ssl_ca_cert_id = cert.id
      @fedora_root.save!
      assert @fedora_root.pulp_update_needed?

      @fedora_root = @fedora_root.reload
      refute @fedora_root.pulp_update_needed?
      @fedora_root.ssl_client_cert_id = cert.id
      @fedora_root.save!
      assert @fedora_root.pulp_update_needed?

      @fedora_root = @fedora_root.reload
      refute @fedora_root.pulp_update_needed?
      @fedora_root.ssl_client_key_id = cert.id
      @fedora_root.save!
      assert @fedora_root.pulp_update_needed?
    end
  end

  class RootRepositoryAuditTest < RepositoryTestBase
    def setup
      super
      User.current = @admin
      @product = katello_products(:fedora)
      @fedora_root = build(:katello_root_repository, :fedora_17_el6_root, :product => @product)
    end

    def test_audit_on_repo_creation
      assert_difference 'Audit.count' do
        @fedora_root.save!
      end
      recent_audit = @fedora_root.audits.last
      assert_equal 'create', recent_audit.action
    end

    def test_audit_on_repo_destroy
      @fedora_root.save!
      assert_difference 'Audit.count' do
        @fedora_root.destroy
      end
      recent_audit = Audit.last
      assert_equal 'Katello::RootRepository', recent_audit.auditable_type
      assert_equal 'destroy', recent_audit.action
    end

    def test_audit_hook_to_find_records_should_return_content
      @fedora_root.save!
      content_id = 'dummycontent-123'
      content = FactoryBot.create(:katello_content, cp_content_id: content_id, :organization_id => @product.organization_id)
      FactoryBot.create(:katello_product_content, content: content, product: @product)
      @fedora_root.update!(content_id: content_id)
      @audit_record = @fedora_root.audits.where(:action => 'update').first
      refute_empty @audit_record.audited_changes['content_id']
      assert_nil Katello::RootRepository.reflect_on_association('content')

      content_by_audit_record = Katello::RootRepository.audit_hook_to_find_records(
        'content_id', @audit_record.audited_changes['content_id'][1], @audit_record
      )
      assert content_by_audit_record, 'No content record found by method #audit_hook_to_find_records'
      assert_equal Katello::Content, content_by_audit_record.class
    end
  end
end
