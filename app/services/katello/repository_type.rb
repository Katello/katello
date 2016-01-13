module Katello
  class RepositoryType
    class << self
      def def_field(*names)
        class_eval do
          names.each do |name|
            define_method(name) do |*args|
              args.empty? ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", *args)
            end
          end
        end
      end
    end

    def_field :allow_creation_by_user
    attr_reader :id

    def initialize(id)
      @id = id.to_sym
      allow_creation_by_user(true)
    end

    def <=>(other)
      self.id.to_s <=> other.id.to_s
    end

    def as_json(options = {})
      ret = super(options)
      ret[:name] = self.id.to_s
      ret[:creatable] = @allow_creation_by_user
      ret.delete("allow_creation_by_user")
      ret
    end
  end
end
