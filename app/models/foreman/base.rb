class Foreman::Base
  include ActiveModel::Serialization
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :errors

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    @errors = ActiveModel::Errors.new(self)
  end

  def persisted?
    false
  end

  # needed for ActiveRecord::Errors
  def read_attribute_for_validation(attr)
    send(attr)
  end

  def resource
    self.class.resource
  end

  def save
    if id.blank?
      resource.create resource_name => as_json
    else
      resource.update id, resource_name => as_json
    end
    self
  rescue RestClient::UnprocessableEntity => e
    response = JSON.parse(e.response)
    response[resource_name]['errors'].each { |key, val| errors.add(key, val) }
    raise ActiveRecord::RecordInvalid.new(self)
  end

  def resource_name
    self.class.resource_name
  end

  def as_json(options = {})
    self.class.instance_variable_get("@json_fields").inject({}) do |memo, field|
      memo[field.to_s] = instance_variable_get("@#{field}")
      memo
    end
  end

  class << self

    def resource_name
      @resource_name ||= self.name.demodulize.downcase
    end

    def json_fields *fields
      @json_fields = fields
    end

    def find id
      new(resource.show(id).first[resource_name])
    rescue RestClient::ResourceNotFound => e
      raise ActiveRecord::RecordNotFound.new(e)
    end

    def all
      resource.index.first.map { |data| new(data[resource_name]) }
    end

    def delete id
      resource.destroy(id).first
      true
    rescue RestClient::ResourceNotFound => e
      raise ActiveRecord::RecordNotFound.new(e)
    end

    # needed for ActiveRecord::Errors
    def human_attribute_name(attr, options = {})
      attr
    end

    # needed for ActiveRecord::Errors
    def lookup_ancestors
      [self]
    end

  end

end