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
    end
  end

  def initialize(attrs = {})
    attrs.each {|key, val| self.send("#{key}=", val)}
  end

  def display_attributes
    self.class.get_display_attributes
  end

  def as_json(options = {})
    json = {}
    raise "Display attributes not defined for #{self.class.name}" if display_attributes.nil? || display_attributes.empty?
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
      @display_attributes = attrs
      attr_accessor *attrs
    end

    def get_display_attributes
      @display_attributes || self.superclass.get_display_attributes
    end

  end

end
