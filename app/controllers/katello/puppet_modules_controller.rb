module Katello
  class PuppetModulesController < Katello::ApplicationController
    before_filter :find_puppet_module, only: [:show]

    def show
      render :partial => "show"
    end

    private

    def find_puppet_module
      @puppet_module = PuppetModule.find(params[:id])
    end
  end
end
