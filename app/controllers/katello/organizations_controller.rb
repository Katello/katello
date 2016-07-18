module Katello
  class OrganizationsController < Katello::ApplicationController
    before_action :search_filter, :only => [:auto_complete_search]

    def rules
      {
        :auto_complete_search => lambda { Organization.any_readable? },
        :default_label => lambda { Organization.creatable? }
      }
    end

    def section_id
      'operations'
    end

    protected

    def search_filter
      @filter = {:organization_id => current_organization}
    end

    def controller_display_name
      return 'organization'
    end

    private

    def default_notify_options
      super.merge :organization => nil
    end
  end
end
