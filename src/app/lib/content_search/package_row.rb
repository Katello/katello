#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module ContentSearch

  class PackageRow < Row
    include ContentSearchHelper
    attr_accessor :package

    def initialize(options)
      super
      build_row
    end

    def build_row
      self.data_type ||= type
      self.cols ||= {}
      self.id ||= build_id
      self.name ||= build_display
      self.value ||= package.nvrea
    end

    def build_display
      is_package? ? package_display(package) : errata_display(package)
    end

    def build_id
      [self.parent_id, "package", package.id].select(&:present?).join("_")
    end

    def type
      package.class.name.underscore
    end

    def is_package?
      type == "package"
    end

    def short_details_erratum_path(*args)
      ActionController::Base.config.relative_url_root + Rails.application.routes.url_helpers.short_details_erratum_path(*args)
    end
  end
end
