#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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

  include ActiveModel::Naming

  def self.name
    # strip namespaces from class name
    # eg. Foreman::SomeModel -> SomeModel
    super.split('::')[-1]
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

  # @return Hash of errors (key is attribute name, value is error message)
  def parse_errors(hash)
    raise NotImplementedError
  end

  # @return array of parsed attributes
  def self.parse_attributes(data)
    raise NotImplementedError
  end

  public


  attributes :id

  def initialize(attributes = { })
    self.attributes = attributes
    @persisted      = false
  end

  def attributes=(attributes)
    return if attributes.blank?
    attributes = attributes.stringify_keys
    self.class.attributes.each do |name|
      __send__(:"#{name}=", attributes.delete(name.to_s)) if attributes.has_key? name.to_s
    end
    raise ArgumentError, "unknown attributes: #{attributes.keys.join(', ')}" unless attributes.empty?
  end

  singleton_class.instance_eval { attr_writer :resource }

  def self.resource
    @resource
  end

  def resource
    self.class.resource
  end

  def persisted?
    @persisted
  end

  def set_as_persisted
    @persisted = true
  end
  private :set_as_persisted

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
    parse_errors(response).each { |key, val| errors.add key, val }
    return false
  end

  def create
    data, response = resource.create as_json(json_create_options), self.class.header
    self.id        = data[resource_name]['id']
    set_as_persisted
    return data, response
  end

  def update
    return resource.update({ 'id' => id }.merge(as_json(json_update_options)),
                           self.class.header)
  end

  def save!
    save or raise Invalid.new(self)
  end

  singleton_class.instance_eval { attr_writer :resource_name }

  def self.resource_name
    @resource_name ||= self.name.demodulize.underscore.downcase
  end

  def resource_name
    self.class.resource_name
  end

  def destroy
    self.class.delete id
  end

  def destroy!
    self.class.delete! id
  end

  def self.find!(id)
    data, _ = resource.show({ 'id' => id }, header)
    new(clean_attribute_hash(parse_attributes(data))).tap do |o|
      o.send :set_as_persisted
    end
  rescue RestClient::ResourceNotFound => e
    raise NotFound.new(self, id)
  end

  def self.find(id)
    find!(id)
  rescue NotFound
    nil
  end

  def self.all(params = nil)
    items, _ = resource.index(params, header)
    items.map do |item|
      new(clean_attribute_hash(parse_attributes(item))).tap do |o|
        o.send :set_as_persisted
      end
    end
  end

  def self.delete!(id)
    resource.destroy({ 'id' => id }, header)
    true
  rescue RestClient::ResourceNotFound => e
    raise NotFound.new(self, id)
  end

  def self.delete(id)
    delete!(id)
  rescue NotFound
    false
  end

  def to_key
    key = self.id
    [key] if key
  end

  private

  singleton_class.instance_eval { attr_writer :current_user_getter }

  def self.get_current_user
    @current_user_getter.try(:call) or
        User.current or
        raise 'current user is not set'
  end

  def self.header
    { }
  end

  def self.clean_attribute_hash(attributes)
    attributes.reject { |k, _| not self.attributes.map(&:to_s).include? k.to_s }
  end

end
