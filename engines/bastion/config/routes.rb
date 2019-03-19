Foreman::Application.routes.draw do
  class BastionPagesConstraint
    def matches?(request)
      pages.include?(request.params[:bastion_page])
    end

    private

    def pages
      pages = Bastion.plugins.collect { |_name, plugin| plugin[:pages] }
      pages.flatten
    end
  end

  scope :module => :bastion do
    get '/:bastion_page/(*path)', :to => "bastion#index", constraints: BastionPagesConstraint.new
    get '/bastion/(*path)', :to => "bastion#index_ie"
  end
end
