class Resources::ForemanModel

  class Error < StandardError
  end

  class NotFound < Error
    attr_reader :resource_class, :id

    def initialize(resource_class, id)
      @resource_class, @id = resource_class, id
      super("#{resource_class} with id '#{id}' not found")
    end
  end

  class Invalid < Error
    attr_reader :resource

    def initialize(resource)
      @resource = resource
      super("#{resource.class} with id '#{resource.id}' is invalid:\n" +
                resource.errors.full_messages.map { |m| "- " + m }.join("\n"))
    end
  end

  class_attribute :_attributes, :instance_reader => false, :instance_writer => false

  # @param [Array<Symbol>] attrs of attribute names
  def self.attributes(*attrs)
    if attrs.empty?
      _attributes or raise 'not yet defined'
    else
      self._attributes ||= []
      self._attributes += attrs

      attrs.each { |name| attr_accessor name }
    end
  end


  include ActiveModel::Validations

  def read_attribute_for_validation(key)
    __send__ key
  end

  def self.humanize_class_name(name = nil)
    name ||= self.to_s
    name.underscore.humanize
  end


  include ActiveModel::Serializers::JSON

  def attributes
    self.class.attributes.inject({ }) do |hash, attr_name|
      hash[attr_name.to_s] = __send__ attr_name
      hash
    end
  end

  def as_json(options = nil)
    options ||= json_default_options
    super options
  end

  protected

  def json_default_options
    raise NotImplementedError
  end

  def json_create_options
    json_default_options
  end

  def json_update_options
    json_default_options
  end

  public


  attributes :id

  def initialize(attributes = { })
    self.attributes = attributes
  end

  def attributes=(attributes)
    attributes = attributes.stringify_keys
    self.class.attributes.each do |name|
      __send__(:"#{name}=", attributes.delete(name.to_s)) if attributes.has_key? name.to_s
    end
    raise ArgumentError, "unknown attributes: #{attributes.keys.join(', ')}" unless attributes.empty?
  end

  def self.resource
    Resources::Foreman.const_get to_s.demodulize
  rescue NameError => e
    if e.message =~ /Resources::Foreman::#{to_s.demodulize}/
      raise "could not find Resources::Foreman::#{to_s.demodulize}, try to override #{to_s}.resource"
    else
      raise e
    end
  end

  def resource
    self.class.resource
  end

  def persisted?
    not id.blank?
  end

  def save
    return false unless valid?

    if persisted?
      update
    else
      create
    end

    return true
  rescue RestClient::UnprocessableEntity => e
    response = JSON.parse(e.response)
    response[resource_name]['errors'].each { |key, val| errors.add key, val }
    return false
  end

  def create
    data, response = resource.create as_json(json_create_options), self.class.foreman_header
    self.id        = data['user']['id']
    return data, response
  end

  def update
    return resource.update(id, as_json(json_update_options), self.class.foreman_header)
  end

  def save!
    save or raise Invalid.new(self)
  end

  def self.resource_name
    @resource_name ||= self.name.demodulize.downcase
  end

  def resource_name
    self.class.resource_name
  end

  def destroy
    self.class.delete id
  end

  def self.find!(id)
    new clean_attribute_hash(resource.show(id, foreman_header).first[resource_name])
  rescue RestClient::ResourceNotFound => e
    raise NotFound.new(self, id)
  end

  def self.find(id)
    find!(id)
  rescue NotFound
    nil
  end

  def self.all
    resource.index(foreman_header).first.map { |data| new clean_attribute_hash(data[resource_name]) }
  end

  def self.delete!(id)
    resource.destroy(id, foreman_header).first
    true
  rescue RestClient::ResourceNotFound => e
    raise NotFound.new(self, id)
  end

  def self.delete(id)
    delete!(id)
  rescue NotFound
    false
  end

  private

  def self.foreman_header
    raise 'current user is not set' unless User.current
    { :foreman_user => User.current.username }
  end

  def self.clean_attribute_hash(attributes)
    attributes.reject { |k, _| not self.attributes.map(&:to_s).include? k.to_s }
  end

end
