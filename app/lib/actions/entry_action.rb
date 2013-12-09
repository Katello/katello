module Actions

  class EntryAction < Actions::Action
    include Helpers::ArgsSerialization
    include Helpers::Lock
    include Helpers::NewLock

    # what locks to use on the resource? All by default, can be overriden
    def resource_locks
      :all
    end

    # Peforms all that's needed to connect the action to the resource.
    # It converts the resource (and it's relatives defined in +related_resources+
    # to serialized form (using +to_action_input+).
    #
    # It also locks the resource on the actions defined in +resource_locks+ method.
    #
    # The additional args can include more resources and/or a hash
    # with more data describing the action that should appear in the
    # action's input.
    def action_subject(resource, *additional_args)
      if resource.respond_to?(:related_resources_recursive)
        related_resources = resource.related_resources_recursive
      else
        related_resources = []
      end
      plan_self(serialize_args(resource, *related_resources, *additional_args))
      if resource.is_a? ActiveRecord::Base
        lock(resource, resource_locks)
        lock!(resource, resource_locks)
      end
    end

    def humanized_input
      Helpers::Humanizer.new(self).input
    end

  end
end
