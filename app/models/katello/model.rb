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

    def destroy!
      unless destroy
        fail self.errors.full_messages.join('; ')
      end
    end
  end
end
