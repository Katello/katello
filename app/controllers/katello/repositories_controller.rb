module Katello
  class RepositoriesController < Katello::ApplicationController
    respond_to :html, :js

    def auto_complete_library
      # retrieve and return a list (array) of repo names in library that contain the 'term' that was passed in
      query = "name_autocomplete:#{params[:term]}"

      ids = []
      ids += Product.readable_repositories.pluck("#{Katello::Repository.table_name}.id") if Product.readable?
      ids += ContentView.readable_repositories.pluck(:library_instance_id)
      ids.uniq!

      repos = Repository.search do
        query do
          string query
        end
        filter :terms, :id => ids
      end

      render :json => (repos.map do |repo|
        label = _("%{repo} (Product: %{product})") % {:repo => repo.name, :product => repo.product}
        {:id => repo.id, :label => label, :value => repo.name}
      end)
    end
  end
end
