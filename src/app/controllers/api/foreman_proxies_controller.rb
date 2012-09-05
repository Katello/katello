class Api::ForemanProxiesController < Api::ApiController
  skip_before_filter :authorize # TODO

  def self.foreman_model(a_model_class)
    singleton_class.instance_variable_set("@foreman_model", a_model_class)
  end

  def foreman_model
    retval = singleton_class.instance_variable_get("@foreman_model")
    raise ArgumentError, "Please specify foreman model class using 'foreman_model ClassName' in class definition." if retval.nil?
    retval
  end

  def index
    render :json => foreman_model.all
  end

  def show
    render :json => foreman_model.find!(params[:id])
  end

  def create
    resource = foreman_model.new(params[hash_parameter_name_from_model_class])
    if resource.save!
      render :json => resource
    end
  end

  def update
    resource = foreman_model.find!(params[:id])
    resource.attributes = params[hash_parameter_name_from_model_class]
    if resource.save!
      render :json => resource
    end
  end

  def destroy
    if foreman_model.delete!(params[:id])
      render :nothing => true
    end
  end

  protected
  def hash_parameter_name_from_model_class
    foreman_model.to_s.demodulize.downcase.to_sym
  end
end
