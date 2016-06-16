class RemoveDuplicateViewFilters < ActiveRecord::Migration
  class Role < ActiveRecord::Base
  end

  class Filter < ActiveRecord::Base
    belongs_to :role
    has_many :filterings, :dependent => :destroy
    has_many :permissions, :through => :filterings

    scope :unlimited, -> { where(:search => nil, :taxonomy_search => nil) }
  end

  class Filtering < ActiveRecord::Base
    belongs_to :filter
    belongs_to :permission
  end

  class Permission < ActiveRecord::Base
    has_many :filterings, :dependent => :destroy
    has_many :filters, :through => :filterings
  end

  def up
    viewer_role = Role.find_by(:name => "Viewer")
    permissions = [:view_activation_keys, :view_content_hosts,
                   :view_content_views, :view_gpg_keys, :view_host_collections,
                   :view_lifecycle_environments, :view_products,
                   :view_subscriptions, :view_sync_plans]

    permissions.each do |perm_name|
      permission = Permission.find_by(:name => perm_name)
      next unless permission
      filters = Filter.unlimited.joins(:permissions).where(:role => viewer_role,
                                                           "permissions.id" => [permission.id])
      filters.drop(1).each(&:destroy)
    end
  end
end
