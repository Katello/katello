class Api::Foreman::SimpleCrudController < Api::ApiController

  def rules
    superadmin_test = lambda { current_user.has_superadmin_role? }
    actions         = [:index, :show, :create, :update, :destroy]

    actions.inject({ }) { |hash, action| hash[action] = superadmin_test; hash }
  end

  def index(request_options = nil)
    render :json => foreman_model.all(request_options)
  end

  def show
    render :json => foreman_model.find!(params[:id])
  end

  def create
    resource = foreman_model.new(params[foreman_model.resource_name])
    if resource.save!
      render :json => resource
    end
  end

  def update
    resource            = foreman_model.find!(params[:id])
    resource.attributes = params[foreman_model.resource_name]
    if resource.save!
      render :json => resource
    end
  end

  def destroy
    if foreman_model.delete!(params[:id])
      render :nothing => true
    end
  end

  singleton_class.send :attr_reader, :foreman_model

  private

  singleton_class.send :attr_writer, :foreman_model

  def foreman_model
    self.class.foreman_model or
        raise ArgumentError,
              "Please specify foreman model class using 'self.foreman_model = ClassName' in #{self.class} definition."
  end

end
