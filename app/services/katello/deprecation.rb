module Katello
  class Deprecation
    class << self; attr_accessor :deprecations end

    # Structure of Deprecation warning object:
    # reference_key : {
    #   removal_version: Katello version that the deprecated behavior will be removed by. This value is used in
    #                    testing to compare to the current Katello version, failing if it is less than the current version.
    #   item:            The part of the application being removed or modified.
    #   action_message:  A follow up message giving an actionable instruction to the user. e.g. "Please use foo instead."
    # }
    @deprecations = {
      host_subs_content_label: {
        removal_version: 3.5,
        item: "The parameter content_label",
        action_message: "Please update to use the content_overrides parameter."
      }
    }.with_indifferent_access

    # Pass in caller(0) to ensure the correct line of source code is referenced
    def self.api_deprecation_warning(deprecation_key, my_caller = caller)
      dep_info = deprecations[deprecation_key]
      warning = "#{dep_info[:item]} will be removed in Katello #{dep_info[:removal_version]} or " \
                "the equivalent version. #{dep_info[:action_message]}"
      ::Foreman::Deprecation.api_deprecation_warning(warning, my_caller)
    end
  end
end