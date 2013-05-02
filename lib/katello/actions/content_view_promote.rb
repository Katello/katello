module Katello
  module Actions
    class ContentViewPromote < Dynflow::Action

      def plan(content_view, from_env, to_env)
        plan_self('id' => content_view.id,
                  'label' => content_view.label,
                  'org_label' => content_view.organization.label,
                  'from_env_label' => from_env.label,
                  'to_env_label' => to_env.label)
      end

      input_format do
        param :id, Integer
        param :label, String
        param :org_label, String
        param :from_env_label, String
        param :to_env_label, String
      end

    end
  end
end
