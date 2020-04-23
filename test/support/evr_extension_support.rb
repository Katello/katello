module Katello
  module EvrExtensionSupport
    extend ActiveSupport::Concern

    def self.set_rpm_evrs
      ::ActiveRecord::Migration[5.2].execute <<-SQL
        update katello_rpms SET evr = (ROW(coalesce(epoch::numeric,0),
                                           rpmver_array(coalesce(version,'empty'))::evr_array_item[],
                                           rpmver_array(coalesce(release,'empty'))::evr_array_item[])::evr_t);
      SQL
    end

    def self.set_installed_package_evrs
      ::ActiveRecord::Migration[5.2].execute <<-SQL
        update katello_installed_packages SET evr = (ROW(coalesce(epoch::numeric,0),
                                           rpmver_array(coalesce(version,'empty'))::evr_array_item[],
                                           rpmver_array(coalesce(release,'empty'))::evr_array_item[])::evr_t);
      SQL
    end
  end
end
