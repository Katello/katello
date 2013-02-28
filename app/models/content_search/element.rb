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

module ContentSearch::Element

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      class << self
        alias_method_chain :attr_accessor, :saved_attributes
      end
    end
  end

  def initialize(attrs = {})
    attrs.each {|key, val| self.send("#{key}=", val)}
  end

  def attributes
    self.class.get_element_attributes || self.class.attributes
  end

  def as_json(options = {})
    json = {}
    attributes.each do |attr|
      json[attr] = self.send(attr) if self.send(attr)
    end
    json
  end

  module ClassMethods

    def attr_accessor_with_saved_attributes(*names)
      @attributes = names
      attr_accessor_without_saved_attributes(*names)
    end

    def attributes
      @element_attributes || @attributes
    end

    def element_attributes(*attrs)
      @element_attributes = attrs
    end

    def get_element_attributes
      @element_attributes
    end

  end

end
