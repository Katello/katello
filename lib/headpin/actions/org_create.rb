module Headpin
  module Actions
    class OrgCreate < Dynflow::Action

      def plan(organization)
        plan_self('name' => organization.name, 'label' => organization.label)
      end

      input_format do
        param :name, String
        param :label, String
      end

    end
  end
end
