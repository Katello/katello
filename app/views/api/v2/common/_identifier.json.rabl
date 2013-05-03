attributes :id, :name
attributes :label if @object.respond_to? :label
attributes :description if @object.respond_to? :description
