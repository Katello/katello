class RepositoryAddContentView < ActiveRecord::Migration
  class Organization < ActiveRecord::Base
    has_many :environments, :class_name => "KTEnvironment", :dependent => :destroy, :inverse_of => :organization
  end
  class KTEnvironment < ActiveRecord::Base
    self.table_name = "environments"
    has_many :repositories, :through => :environment_products
    belongs_to :organization, :inverse_of => :environments
    has_many :environment_products, :foreign_key => "environment_id"

    def default_content_view
      ContentView.find_find_by_id(default_content_view_id)
    end
  end
  class EnvironmentProduct < ActiveRecord::Base
    has_many :repositories
    belongs_to :environment, :class_name => "KTEnvironment"
  end
  class Repository < ActiveRecord::Base
    belongs_to :environment_product
    belongs_to :content_view_version
  end
  class ContentViewVersion < ActiveRecord::Base
    has_many :repositories, :dependent => :destroy
    belongs_to :content_view
  end
  class ContentView < ActiveRecord::Base
    include Ext::LabelFromName
    has_many :content_view_versions, :dependent => :destroy
  end

  def self.up
    add_column :repositories, :content_view_version_id, :integer, :null => true
    add_index :repositories, :content_view_version_id

    KTEnvironment.reset_column_information
    Repository.reset_column_information

    User.current = User.hidden.first
    KTEnvironment.all.each do |env|
      view = ContentView.create!(:name => "Default View for #{env.name}",
                                 :organization_id => env.organization_id, :default => true)
      env.default_content_view_id = view.id
      env.save!
      version = ContentViewVersion.create!(:version => 1, :content_view => view)
      env.repositories.each do |repo|
        repo.content_view_version = version
        repo.save!
      end
    end

    null_repos = Repository.where(:content_view_version_id => nil)
    if !null_repos.empty?
      puts "Found null content_view_version repositories"
      puts null_repos.inspect
    end
    change_column :repositories, :content_view_version_id, :integer, :null => false
  end

  def self.down
    KTEnvironment.all.each do |env|
      env.default_content_view.destroy!
    end
    remove_column :repositories, :content_view_version_id
  end
end
