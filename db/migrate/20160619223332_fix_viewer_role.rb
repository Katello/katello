class FixViewerRole < ActiveRecord::Migration
  class Role < ApplicationRecord
    has_many :filters
  end

  class Filter < ApplicationRecord
    belongs_to :role
    has_many :filterings, :dependent => :destroy
    has_many :permissions, :through => :filterings

    scope :unlimited, -> { where(:search => nil, :taxonomy_search => nil) }

    def resource_type
      type = @resource_type || permissions.first.try(:resource_type)
      type.blank? ? nil : type
    end
  end

  class Filtering < ApplicationRecord
    belongs_to :filter
    belongs_to :permission
  end

  class Permission < ApplicationRecord
  end

  def change
    viewer = Role.find_by name: 'Viewer'
    view_permission = Permission.find_by name: 'view_content_views'

    unless viewer.nil?
      filters = viewer.filters.unlimited.select { |filter| filter.resource_type == 'Katello::ContentView' }
      unless filters.empty?
        filters.each do |filter|
          unwanted_filterings = filter.filterings.select { |filtering| filtering.permission_id != view_permission.id }
          filter.filterings.delete(unwanted_filterings)
        end
      end
    end
  end
end
