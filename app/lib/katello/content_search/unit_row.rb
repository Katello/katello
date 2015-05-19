module Katello
  module ContentSearch
    class UnitRow < Row
      include ContentSearchHelper
      attr_accessor :unit # :package, :errata, :puppet_module

      def initialize(options)
        super
        build_row
      end

      def build_row
        self.data_type ||= type
        self.cols ||= {}
        self.id ||= build_id

        case type
        when "package"
          self.name ||= package_display(unit)
          self.value ||= unit.nvrea
        when "errata"
          self.name ||= errata_display(unit)
          self.value ||= unit.id
        when "puppet_module"
          self.name ||= puppet_module_display(unit)
          self.value ||= unit.name
        end
      end

      def build_id
        [self.parent_id, "package", unit.id].select(&:present?).join("_")
      end

      def type
        unit.class.name.gsub('Katello::', '').underscore
      end

      def short_details_erratum_path(*args)
        ActionController::Base.config.relative_url_root + Rails.application.routes.url_helpers.short_details_erratum_path(*args)
      end
    end
  end
end
