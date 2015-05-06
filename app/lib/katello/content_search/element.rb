module Katello
  module ContentSearch::Element
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    def initialize(attrs = {})
      attrs.each { |key, val| self.send("#{key}=", val) }
    end

    def display_attributes
      self.class.display_attributes
    end

    def as_json(_options = {})
      json = {}
      fail "Display attributes not defined for #{self.class.name}" if display_attributes.nil? || display_attributes.empty?
      display_attributes.each do |attr|
        json[attr] = self.send(attr) if self.send(attr)
      end
      json
    end

    def [](key)
      self.send(key.to_sym)
    end

    def []=(key, val)
      self.send("#{key.to_sym}=", val)
    end

    module ClassMethods
      def display_attributes(*attrs)
        if attrs.empty?
          @display_attributes || self.superclass.display_attributes
        else
          @display_attributes = attrs
          attr_accessor(*attrs)
        end
      end
    end
  end
end
