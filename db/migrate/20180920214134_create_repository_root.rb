class CreateRepositoryRoot < ActiveRecord::Migration[5.1]
  MOVED_COLUMNS = %w(name created_at updated_at major minor gpg_key_id content_id arch label url unprotected
                     content_type product_id docker_upstream_name mirror_on_sync download_policy
                     verify_ssl_on_sync upstream_username upstream_password ostree_upstream_sync_policy ostree_upstream_sync_depth
                     deb_releases deb_components deb_architectures ignore_global_proxy ssl_ca_cert_id
                     ssl_client_cert_id ssl_client_key_id ignorable_content description docker_tags_whitelist).freeze

  REPO_ASSOCIATIONS = %w(RepositoryErratum ContentViewRepository RepositoryRpm RepositorySrpm RepositoryFileUnit RepositoryPuppetModule
                         RepositoryDockerManifest RepositoryDockerManifestList DockerTag DockerMetaTag RepositoryOstreeBranch RepositoryDeb
                         ContentFacetRepository RepositoryPackageGroup RepositoryModuleStream).freeze

  REPO_ASSOCIATIONS.each do |association|
    CreateRepositoryRoot.const_set("Fake#{association}",
       Class.new(Katello::Model) do
         self.table_name = "katello_#{association.underscore.pluralize}"
         belongs_to :repository, :inverse_of => association.underscore.to_sym,
                                 :class_name => "FakeRepository"
       end
                                  )
  end

  class FakeContentFacet < Katello::Model
    self.table_name = 'katello_content_facets'
    belongs_to :kickstart_repository, :class_name => "CreateRepositoryConfiguration::FakeRepository", :inverse_of => :kickstart_content_facets
  end

  class FakeHostgroup < Katello::Model
    self.table_name = 'hostgroups'
    belongs_to :kickstart_repository, :class_name => "CreateRepositoryConfiguration::FakeRepository", :inverse_of => :kickstart_hostgroups
  end

  class FakeRepository < Katello::Model
    self.table_name = 'katello_repositories'

    REPO_ASSOCIATIONS.each do |association|
      has_many association.underscore.pluralize.to_sym, :class_name => "CreateRepositoryConfiguration::Fake#{association}", :dependent => :delete_all, :inverse_of => :repository
    end

    has_many :kickstart_content_facets, :class_name => "CreateRepositoryConfiguration::FakeContentFacet", :foreign_key => :kickstart_repository_id,
                          :inverse_of => :kickstart_repository, :dependent => :nullify

    has_many :kickstart_hostgroups, :class_name => "CreateRepositoryConfiguration::FakeHostgroup", :foreign_key => :kickstart_repository_id,
             :inverse_of => :kickstart_repository, :dependent => :nullify
  end

  class FakeRootRepository < Katello::Model
    self.table_name = 'katello_root_repositories'
  end

  def up
    create_root_table

    with_repository_root_id do
      create_and_associate_roots
      FakeRepository.where(:root_id => nil).destroy_all
    end

    update_repository_table
  end

  def create_and_associate_roots
    FakeRepository.where(:library_instance_id => nil).each do |library_instance|
      clones = FakeRepository.where(:library_instance_id => library_instance.id).to_a
      root = create_root(library_instance)
      (clones + [library_instance]).each do |repo|
        repo.update_attributes!(:root_id => root.id)
      end
    end
  end

  def with_repository_root_id
    add_column :katello_repositories, :root_id, :integer, :null => true
    add_foreign_key "katello_repositories", "katello_root_repositories", :name => "katello_root_repositories_repo_id", :column => 'root_id'

    yield

    change_column :katello_repositories, :root_id, :integer, :null => false
  end

  def create_root(repo)
    attributes = repo.attributes.slice(*MOVED_COLUMNS)
    attributes[:checksum_type] = repo.checksum_type || repo.source_repo_checksum_type
    FakeRootRepository.create!(attributes)
  end

  # rubocop:disable Metrics/MethodLength
  def create_root_table
    create_table 'katello_root_repositories' do |t|
      t.string 'name', limit: 255
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.integer 'major'
      t.string 'minor', limit: 255
      t.integer 'gpg_key_id'
      t.string 'content_id', limit: 255
      t.string 'arch', limit: 255, default: 'noarch', null: false
      t.string 'label', limit: 255, null: false
      t.string 'url', limit: 1024
      t.boolean 'unprotected', default: false, null: false
      t.string 'content_type', limit: 255, default: 'yum', null: false
      t.integer 'product_id'
      t.string 'checksum_type', limit: 255
      t.string 'pulp_scratchpad_checksum_type', limit: 255
      t.string 'docker_upstream_name', limit: 255
      t.boolean 'mirror_on_sync', default: true, null: false
      t.string 'download_policy', limit: 255
      t.boolean 'verify_ssl_on_sync', default: true, null: false
      t.string 'upstream_username', limit: 255
      t.string 'upstream_password', limit: 1024
      t.string 'ostree_upstream_sync_policy', limit: 25
      t.integer 'ostree_upstream_sync_depth'
      t.string 'deb_releases', limit: 255
      t.string 'deb_components', limit: 255
      t.string 'deb_architectures', limit: 255
      t.boolean 'ignore_global_proxy', default: false, null: false
      t.integer 'ssl_ca_cert_id'
      t.integer 'ssl_client_cert_id'
      t.integer 'ssl_client_key_id'
      t.text 'ignorable_content'
      t.text 'docker_tags_whitelist'
      t.text 'description'
    end

    add_foreign_key "katello_root_repositories", "katello_products", :name => "katello_root_repositories_product_id", :column => 'product_id'
    add_foreign_key "katello_root_repositories", "katello_gpg_keys", :name => "katello_root_repositories_gpg_key_id", :column => 'gpg_key_id'
    add_foreign_key "katello_root_repositories", "katello_gpg_keys", :name => "katello_root_repositories_ssl_ca_cert_id", :column => 'ssl_ca_cert_id'
    add_foreign_key "katello_root_repositories", "katello_gpg_keys", :name => "katello_root_repositories_ssl_client_cert_id", :column => 'ssl_client_cert_id'
    add_foreign_key "katello_root_repositories", "katello_gpg_keys", :name => "katello_root_repositories_ssl_client_key_id", :column => 'ssl_client_key_id'
  end

  def update_repository_table
    rename_column :katello_repositories, :checksum_type, :saved_checksum_type
    remove_column :katello_repositories, :source_repo_checksum_type
    MOVED_COLUMNS.each do |column|
      remove_column :katello_repositories, column
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
