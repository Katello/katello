module Katello
  # The TaxonomyHelper contains extensions to the core application's
  # TaxonomyHelper
  module TaxonomyHelper
    def service_level_options
      options = @taxonomy.service_levels.collect { |level| [_("Service Level %s") % level, level] }
      options.unshift([_("No Service Level Preference"), ""])
      options
    end

    def service_level_selected
      @taxonomy.service_level.blank? ? "" : @taxonomy.service_level
    end
  end
end
