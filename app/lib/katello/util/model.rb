module Katello
  module Util
    module Model
      # hardcoded model names (uses kp_ prefix)
      def self.table_to_model_hash
        {
          "kt_environment" => "KTEnvironment",
        }
      end

      # convert Rails Model name to Class or nil when no such table name exists
      def self.table_to_class(name)
        class_name = table_to_model_hash[name] || name.classify
        class_name.constantize
      rescue NameError
        # constantize throws NameError
        return nil
      end

      def self.labelize(name)
        if name
          (name.ascii_only? && name.length <= 128) ? name.gsub(/[^a-z0-9\-_]+/i, "_") : uuid
        end
      end

      def self.uuid
        SecureRandom.uuid
      end

      def self.controller_path_to_model_hash
        {
          "katello/environments" => "Katello::KTEnvironment",
        }
      end

      def self.controller_path_to_model(controller)
        if controller_path_to_model_hash.key? controller.to_s
          controller_path_to_model_hash[controller.to_s].constantize
        else
          controller.to_s.classify.constantize
        end
      end

      def self.model_to_controller_path_hash
        controller_path_to_model_hash.invert
      end

      def self.model_to_controller_path(model)
        if model_to_controller_path_hash.key? model.to_s
          model_to_controller_path_hash[model.to_s]
        else
          model.to_s.underscore.pluralize
        end
      end
    end
  end
end
