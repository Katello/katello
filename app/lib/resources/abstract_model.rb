#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

# {Resources::AbstractModel} is light-weighted representation of remote resources. It behaves similarly as ActiveRecord or ActiveResource.
# {Resources::ForemanModel} is a base class for all foreman remote resources. (There may be CandlepinModel and
# PulpModel in future if we decide to go this way.)
class Resources::AbstractModel
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
      super("#{resource.class}#{resource.id && " with id '#{resource.id}'"} is invalid:\n" +
                resource.errors.full_messages.map { |m| "- " + m }.join("\n"))
    end

    def record
      @resource
    end

  end

  class ResponseParsingError < Error
    def initialize(data)
      super "parsing of response chunk failed: #{data.inspect}"
    end
  end


  class_attribute :_attributes, :instance_reader => false, :instance_writer => false

  # defines which attributes the model has
  # @param [Array<Symbol>] attrs of attribute names
  def self.attributes(*attrs)
    if attrs.empty?
      _attributes or raise 'attributes not yet defined'
    else
      self._attributes ||= []
      self._attributes += attrs

      attrs.each { |name| attr_accessor name }
    end
  end


  extend ActiveModel::Callbacks

  define_model_callbacks :create, :update, :save, :destroy

  include ActiveModel::Naming
  include ActiveModel::Validations

  # @api private
  def read_attribute_for_validation(key)
    __send__ key
  end

  def self.humanize_class_name(name = nil)
    name ||= self.to_s
    name.underscore.humanize
  end


  include ActiveModel::Serializers::JSON

  # @return [Hash] hash of attributes
  def attributes
    self.class.attributes.inject({ }) do |hash, attr_name|
      hash[attr_name.to_s] = __send__ attr_name
      hash
    end
  end

  # @return [Hash, Array] JSON representation of the model in requests
  def as_json(options = nil)
    options ||= json_default_options
    super options
  end

  protected

  # @abstract options for #as_json, used when object is rendered to request
  def json_default_options
    raise NotImplementedError
  end

  def json_create_options
    json_default_options
  end

  def json_update_options
    json_default_options
  end

  # @abstract parse errors from response
  # @param [Hash, Array] response parsed
  # @return [Hash] a hash of errors (key is attribute name, value is error message)
  def parse_errors(response)
    raise NotImplementedError
  end

  # @param [Hash] data parsed response data
  # @return [Hash] parsed attributes
  def self.parse_attributes(data)
    raise NotImplementedError
  end

  public


  attributes :id

  # @param [Hash] attributes
  def initialize(attributes = { })
    self.attributes = attributes
    @persisted      = false
    @destroyed      = false
  end

  # sets attributes of the model
  # @param [Hash] attributes
  def attributes=(attributes)
    return if attributes.blank?
    attributes = attributes.stringify_keys
    self.class.attributes.each do |name|
      __send__(:"#{name}=", attributes.delete(name.to_s)) if attributes.has_key? name.to_s
    end
    raise ArgumentError, "unknown attributes: #{attributes.keys.join(', ')}" unless attributes.empty?
  end

  # @param res set a resource to res if provided
  # @return a resource, e.g. {Resources::Foreman::Architecture}
  def self.resource(res = nil)
    @resource = res unless res.nil?
    @resource
  end

  # @return a resource, e.g. ForemanApi::Resources::Architecture
  def resource
    self.class.resource
  end

  def new_record?
    !self.persisted?
  end

  # @return [true, false] is object persisted?
  def persisted?
    @persisted && !self.destroyed?
  end

  def set_as_persisted
    @persisted = true
  end
  protected :set_as_persisted

  def destroyed?
    @destroyed
  end

  def set_as_destroyed
    @destroyed = true
  end
  private :set_as_destroyed

  # saves the object
  # @return [true,false] true when saved, false when invalid
  def save
    return false unless valid?

    run_callbacks :save do
      if persisted?
        update
      else
        create
      end
    end

    return true
  rescue RestClient::UnprocessableEntity, RestClient::BadRequest => e
    response = JSON.parse(e.response)
    parse_errors(response).each { |key, val| errors.add key, val }
    return false
  end

  def create
    run_callbacks :create do
      data, response = resource.create as_json(json_create_options), self.class.header
      self.id        = self.class.parse_attributes(data)['id']
      set_as_persisted
    end
  end
  private :create

  def update
    run_callbacks :update do
      result = resource.update({ 'id' => id }.merge(as_json(json_update_options)),
                                self.class.header)
    end
  end
  private :update

  # saves the object
  # @raise [Invalid] when invalid
  def save!
    save or raise Invalid.new(self)
  end

  # @param [String] name of the resource to set
  # @return [String] for resource ForemanApi::Resources::Architecture returns "architecture"
  def self.resource_name(name=nil)
    @resource_name ||= self.name.demodulize.underscore.downcase
    @resource_name = name unless name.nil?
    @resource_name
  end

  # @return [String] for resource ForemanApi::Resources::Architecture returns "architecture"
  def resource_name
    self.class.resource_name
  end

  # destroys the model
  # @return [true,false]
  def destroy
    run_callbacks :destroy do
      self.class.delete id
      set_as_destroyed
    end
  end

  # destroys the model
  # @raise [NotFound] when object is missing
  def destroy!
    run_callbacks :destroy do
      self.class.delete! id
      set_as_destroyed
    end
  end

  def self.resource_class(data)
    self
  end

  # find a model by id
  # @param [Integer, String] id
  # @return [AbstractModel]
  # @raise [NotFound] when missing
  def self.find!(id)
    data, _ = resource.show({ 'id' => id }, header)
    self.load_instance(data)
  rescue RestClient::ResourceNotFound => e
    raise NotFound.new(self, id)
  end

  # @see .find!
  # @return [AbstractModel, nil]
  def self.find(id)
    find!(id)
  rescue NotFound
    nil
  end

  # finds collection of models
  # @return [Array<AbstractModel>]
  # @example for Foreman::Architecture
  #   Foreman::Architecture.all
  #   # => [#<Foreman::Architecture:0x108114708 @persisted=true, @name="arch1", @id=4>,
  #   #     #<Foreman::Architecture:0x108113588 @persisted=true, @name="arch2", @id=5>]
  #   Foreman::Architecture.all :search => 'name = arch1'
  #   # => [#<Foreman::Architecture:0x1080d6ea8 @persisted=true, @name="arch1", @id=4>]
  def self.all(params = nil)
    items, _ = resource.index(params, header)
    items.map do |item|
      self.load_instance(item)
    end
  end

  def to_key
    key = self.id
    [key] if key
  end

  def to_param
    id && id.to_s
  end

  def update_attributes(attributes)
    self.attributes = attributes
    save
  end

  def update_attributes!(attributes)
    self.attributes = attributes
    save!
  end

  def self.base_class
    self
  end

  protected

  def self.load_instance(data)
    data = parse_attributes(data)
    klass = self.resource_class(data)
    klass.new(klass.clean_attribute_hash(data)).tap do |o|
      o.send :set_as_persisted
    end
  end

  def self.clean_attribute_hash(attributes)
    attributes.reject { |k, _| not self.attributes.map(&:to_s).include? k.to_s }
  end

  private

  # deletes a model with id
  # @param [String,Integer] id
  # @raise [NotFound] when missing
  def self.delete!(id)
    resource.destroy({ 'id' => id }, header)
    true
  rescue RestClient::ResourceNotFound => e
    raise NotFound.new(self, id)
  end

  # @see .delete!
  # @return [true,false]
  def self.delete(id)
    delete!(id)
  rescue NotFound
    false
  end

  singleton_class.instance_eval { attr_writer :current_user_getter }

  def self.get_current_user
    @current_user_getter.try(:call) or
        User.current or
        raise 'current user is not set'
  end

  # @return [Hash] additional headers for requests
  def self.header
    { }
  end

end
