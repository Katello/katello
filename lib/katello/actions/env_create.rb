module Katello
  module Actions
    class EnvCreate < Dynflow::Action

      def plan(env)
        plan_self('name' => env.name,
                  'label' => env.label,
                  'org_label' => env.organization.label)
      end

      input_format do
        param :name, String
        param :label, String
        param :org_label, String
      end

    end
  end
end
