class MoveDefaultLocationToSettings < ActiveRecord::Migration
  DEFAULT_LOCATION_SETTINGS = ['default_location_subscribed_hosts',
                               'default_location_puppet_content'].freeze
  def up
    default_location = Location.find_by(:katello_default => true)
    if default_location.present?
      DEFAULT_LOCATION_SETTINGS.each do |location_setting|
        Setting.find_by_name(location_setting).update_attribute(
          :value, default_location.title)
      end
    end
    remove_column :taxonomies, :katello_default
  end

  def down
    add_column :taxonomies, :katello_default, :boolean, :null => false,
      :default => false
    DEFAULT_LOCATION_SETTINGS.each do |location_setting|
      default_location = Location.find_by_title(Setting[location_setting])
      if default_location.present?
        default_location.update_attribute(:katello_default, true)
      end
    end
  end
end
