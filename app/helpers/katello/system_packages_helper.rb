module Katello
  module SystemPackagesHelper
    def adding_package
      _("Adding Package...")
    end

    def updating_package
      _("Updating Package...")
    end

    def removing_package
      _("Removing Package...")
    end

    def adding_package_group
      _("Adding Package Group...")
    end

    def removing_package_group
      _("Removing Package Group...")
    end

    def get_status_string(type)
      case type
      when "package_install"
        adding_package
      when "package_update"
        updating_package
      when "package_remove"
        removing_package
      when "package_group_install"
        adding_package_group
      when "package_group_remove"
        removing_package_group
      end
    end

    def row_shading
      @shading = cycle("", "alt")
    end
  end
end
