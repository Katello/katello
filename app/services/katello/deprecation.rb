module Katello
  class Deprecation
    def self.api_deprecation_warning(katello_version_deadline, info)
      ActiveSupport::Deprecation.warn("Your API call uses deprecated behavior, it will be removed in version #{katello_version_deadline}, #{info}", caller)
    end
  end
end
