class AddContentAspect < ActiveRecord::Migration
  # rubocop:disable MethodLength
  def change
    create_table "katello_content_aspects" do |t|
      t.references 'host', :null => false
      t.string 'uuid'
      t.references 'content_view', :null => false, :index => true
      t.references 'lifecycle_environment', :null => false, :index => true
    end

    add_index :katello_content_aspects, [:host_id], :unique => true, :name => :katello_content_aspects_host_id

    add_foreign_key "katello_content_aspects", "hosts",
                    :name => "katello_content_aspects_host_id", :column => "host_id"

    add_foreign_key "katello_content_aspects", "katello_content_views",
                    :name => "katello_content_aspects_content_view_id", :column => "content_view_id"

    add_foreign_key "katello_content_aspects", "katello_environments",
                    :name => "katello_content_aspects_life_environment_id", :column => "lifecycle_environment_id"

    create_table "katello_installed_packages" do |t|
      t.string 'name', :null => false
      t.string 'nvra', :null => false
    end

    create_table "katello_host_installed_packages" do |t|
      t.references 'host', :null => false, :index => true
      t.references 'installed_package', :null => false, :index => true
    end

    add_foreign_key "katello_host_installed_packages", "hosts",
                    :name => "katello_host_installed_packages_host_id", :column => "host_id"

    add_foreign_key "katello_host_installed_packages", "katello_installed_packages",
                    :name => "katello_host_installed_packages_installed_package_id", :column => "installed_package_id"

    create_table "katello_content_aspect_errata" do |t|
      t.references 'content_aspect', :null => false
      t.references 'erratum', :null => false
    end

    add_index :katello_content_aspect_errata, [:erratum_id, :content_aspect_id], :unique => true,
                                                                 :name => :katello_content_aspect_errata_eid_caid

    add_foreign_key "katello_content_aspect_errata", "katello_errata",
                    :name => "katello_content_aspect_errata_errata_id", :column => "erratum_id"
    add_foreign_key "katello_content_aspect_errata", "katello_content_aspects",
                    :name => "katello_content_aspect_errata_ca_id", :column => "content_aspect_id"

    create_table "katello_content_aspect_repositories" do |t|
      t.references 'content_aspect', :null => false
      t.references 'repository', :null => false
    end

    add_index :katello_content_aspect_repositories, [:repository_id, :content_aspect_id], :unique => true,
                                                                 :name => :katello_content_aspect_repository_rid_caid

    add_foreign_key "katello_content_aspect_repositories", "katello_repositories",
                    :name => "katello_content_aspect_repositories_repository_id", :column => "repository_id"
    add_foreign_key "katello_content_aspect_repositories", "katello_content_aspects",
                    :name => "katello_content_aspect_repositories_ca_id", :column => "content_aspect_id"
  end
end
