module Katello
  class RepositoriesController < Katello::ApplicationController
    respond_to :html, :js

    #used by content search
    def auto_complete_library
      repos = []
      repos += Product.readable_repositories.where("#{Repository.table_name}.name ILIKE ?", "#{params[:term]}%") if Product.readable?
      repos += Repository.where(:id => ContentView.readable_repositories.where("#{Repository.table_name}.name ILIKE ?",
                                                                               "#{params[:term]}%").pluck(:library_instance_id))

      render :json => (repos.uniq.map do |repo|
        label = _("%{repo} (Product: %{product})") % {:repo => repo.name, :product => repo.product}
        {:id => repo.id, :label => label, :value => repo.name}
      end)
    end
  end
end
