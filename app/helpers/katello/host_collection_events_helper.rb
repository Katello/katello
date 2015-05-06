module Katello
  module HostCollectionEventsHelper
    def format_description(description)
      description.is_a?(String) ? description.gsub("\n", "<br/>") : description
    end
  end
end
