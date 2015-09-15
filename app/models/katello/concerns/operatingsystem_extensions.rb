module Katello
  module Concerns
    module OperatingsystemExtensions
      extend ActiveSupport::Concern

      included do
        after_create :assign_templates!
      end

      def assign_templates!
        # Automatically assign default templates
        if self.family == 'Redhat'
          TemplateKind.all.each do |kind|
            if (template = ProvisioningTemplate.find_by_name(Setting["katello_default_#{kind.name}"]))
              provisioning_templates << template unless provisioning_templates.include?(template)
              if OsDefaultTemplate.where(:template_kind_id => kind.id, :operatingsystem_id => id).empty?
                OsDefaultTemplate.create(:template_kind_id => kind.id, :provisioning_template_id => template.id, :operatingsystem_id => id)
              end
            end
          end

          if (ptable = Ptable.find_by_name(Setting["katello_default_ptable"]))
            ptables << ptable unless ptables.include?(ptable)
          end
        end
      end
    end
  end
end
