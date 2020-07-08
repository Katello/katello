module Katello
  class Model < ApplicationRecord
    include ActiveModel::ForbiddenAttributesProtection
    self.abstract_class = true

    apipie :prop_group, name: :katello_basic_props do
      meta_example = ", e.g. #{@meta[:example]}" if @meta[:example]
      name_desc = @meta[:name_desc] || "Name of the #{@meta[:friendly_name] || @meta[:class_scope]}#{meta_example}"
      property :name, String, desc: name_desc
      property :label, String, desc: "Label of the #{@meta[:friendly_name] || @meta[:class_scope]}"
    end

    apipie :prop_group, name: :katello_idname_props do
      if @meta[:resource]
        resource = @meta[:resource].humanize(capitalize: false)
        prefix = "#{resource}_"
      end
      property "#{prefix}id".to_sym, Integer, desc: "Returns ID of the #{@meta[:friendly_name] || resource}"
      property "#{prefix}name".to_sym, String, desc: "Returns name of the #{@meta[:friendly_name] || resource}"
    end

    def destroy!
      unless destroy
        fail self.errors.full_messages.join('; ')
      end
    end
  end
end
