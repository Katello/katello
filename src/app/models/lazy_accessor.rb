#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module LazyAccessor

  def self.included(base)
    base.send :include, LazyAccessor::InstanceMethods
    base.send :extend, LazyAccessor::ClassMethods
  end

  module ClassMethods
    # example: lazy_accessor :a, :b, :c,
    #   :initializer => lambda { json = Candlepin::Product.get(cp_id)[0] },
    #   :unless => lambda { cp_id.nil? }
    def lazy_accessor *args
      options = args.extract_options!

      raise ArgumentError, "Attribute names must be symbols" if args.any?{ |attribute| !attribute.is_a?(Symbol) }
      redefined_attr = args.find{ |attribute| instance_methods.include?(attribute.to_s) }
      Rails.logger.warn "Remote attribute '#{redefined_attr}' has already been defined" if redefined_attr

      initializer = options[:initializer]
      raise ArgumentError, "Please provide an initializer" if initializer.nil?

      args.each do |symbol|
        send :define_method, "#{symbol.to_s}_will_change!" do
          changed_remote_attributes[symbol.to_s] ||=
              instance_variable_get("@#{symbol.to_s}").nil? ? remote_attribute_value(symbol.to_s, initializer, args.size > 1) : instance_variable_get("@#{symbol.to_s}")
        end

        send :define_method, "#{symbol.to_s}_changed?" do
          remote_attribute_changed?(symbol.to_s)
        end

        send :define_method, "#{symbol.to_s}_change" do
          attr = symbol.to_s
          if remote_attribute_changed?(attr)
            return [changed_remote_attributes[attr], __send__(attr)]
          end
          nil
        end

        send :define_method, "#{symbol.to_s}_was" do
          attr = symbol.to_s
          remote_attribute_changed?(attr) ? changed_remote_attributes[attr] : __send__(attr)
        end

        send :define_method, "#{symbol.to_s}=" do |val|
          attr = symbol.to_s

          old = instance_variable_get("@#{symbol.to_s}").nil? ? remote_attribute_value(symbol.to_s, initializer, args.size > 1) : instance_variable_get("@#{symbol.to_s}")
          changed_remote_attributes[attr] = old if old != val

          instance_variable_set("@#{attr}", val)
        end

        send :define_method, symbol do
          attr = symbol.to_s

          excepted = options.has_key?(:unless) ? self.instance_eval(&options[:unless]) : new_record?
          if instance_variable_get("@#{attr}").nil? && (not excepted)
            remote_values = run_initializer(args.size > 1, initializer)
            if args.size > 1
              remote_values.each_pair {|k,v| instance_variable_set("@#{k.to_s}", v) if (args.include?(k.to_sym) and respond_to?("#{k.to_s}="))}
            else
              instance_variable_set("@#{attr}", remote_values) if respond_to?("#{attr}=")
            end
          end
          instance_variable_get("@#{attr}")
        end
      end
    end
  end

  module InstanceMethods
    def changed_remote_attributes
      @changed_remote_attributes ||= {}
    end

    def changed_remote_attributes=(val)
      @changed_remote_attributes = val
    end

    def remote_attribute_changed?(attr)
      changed_remote_attributes.has_key?(attr)
    end

    def save(*)
      if status = super
        changed_remote_attributes.clear
      end
      status
    end

    def save!(*)
      super.tap do
        changed_remote_attributes.clear
      end
    end

    def reload(*)
      super.tap do
        changed_remote_attributes.clear
      end
    end

    private
    def remote_attribute_value(attr, initializer, in_group)
      return nil if new_record?

      remote_values = run_initializer(in_group, initializer)
      changed_remote_attributes[attr] = in_group ? remote_values["#{attr}"] : remote_values
    end

    def run_initializer(in_group, initializer)
      remote_values = self.instance_eval(&initializer)
      if in_group && !remote_values.is_a?(Hash)
        raise RuntimeError.new("Expect initializer to return hash if a group of attributes is defined by lazy_accessor")
      end
      remote_values
    end
  end
end
