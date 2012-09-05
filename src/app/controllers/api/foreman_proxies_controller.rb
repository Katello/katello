class Api::ForemanProxiesController < Api::ApiController
  skip_before_filter :authorize # TODO

  def self.foreman_model(a_model_class)
    class_eval do
      define_method(:foreman_model) { a_model_class }
    end
  end

  def index
    render :json => foreman_model.all
  end

  def show
    render :json => foreman_model.find!(params[:id])
  end

  def create
    resource = foreman_model.new(params[:architecture])
    if resource.save!
      render :json => resource
    end
  end

  def update
    resource = foreman_model.find!(params[:id])
    resource.attributes = params[:architecture]
    if resource.save!
      render :json => resource
    end
  end

  def destroy
    if foreman_model.delete!(params[:id])
      render :nothing => true
    end
  end
end
