module Katello
  class PackagesController < Katello::ApplicationController
    before_filter :lookup_package, except: [:auto_complete]

    def auto_complete
      repo_ids = readable_repos(:pulp_id)
      results = Package.autocomplete_name("#{params[:term]}*", repo_ids)

      render :json => results
    end

    def details
      render :partial => "details"
    end

    private

    def lookup_package
      repo_ids = readable_repos(:pulp_id)
      package_id = params[:id]
      @package = Package.find(package_id)
      fail _("Unable to find package %s") % package_id if @package.nil?
      deny_access if (@package.repoids & repo_ids).empty?
    end

    def readable_repos(attribute)
      repos = []
      repos += Product.readable_repositories.pluck(attribute)
      repos += ContentView.readable_repositories.pluck(attribute)
      repos
    end
  end
end
