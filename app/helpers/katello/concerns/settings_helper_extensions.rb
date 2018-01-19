module Katello
  module Concerns
    module SettingsHelperExtensions
      extend ActiveSupport::Concern

      module Overrides
        # rubocop:disable MethodLength
        def value(setting)
          return super(setting) unless [
            'default_download_policy',
            'katello_default_finish',
            'katello_default_iPXE',
            'katello_default_provision',
            'katello_default_ptable',
            'katello_default_PXELinux',
            'katello_default_PXEGrub',
            'katello_default_PXEGrub2',
            'katello_default_user_data',
            'katello_default_kexec',
            'katello_default_atomic_provision'
          ].include?(setting.name)

          case setting.name
          when "default_download_policy"
            edit_select(setting, :value, :select_values => Hash[::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.collect { |p| [p, p] }].to_json)
          when "katello_default_finish"
            edit_select(setting, :value, :select_values => katello_template_setting_values("finish"))
          when "katello_default_iPXE"
            edit_select(setting, :value, :select_values => katello_template_setting_values("iPXE"))
          when "katello_default_provision", "katello_default_atomic_provision"
            edit_select(setting, :value, :select_values => katello_template_setting_values("provision"))
          when "katello_default_ptable"
            edit_select(setting, :value, :select_values => Hash[Template.all.where(:type => "Ptable").map { |tmp| [tmp[:name], tmp[:name]] }].to_json)
          when "katello_default_PXELinux"
            edit_select(setting, :value, :select_values => katello_template_setting_values("PXELinux"))
          when "katello_default_PXEGrub"
            edit_select(setting, :value, :select_values => katello_template_setting_values("PXEGrub"))
          when "katello_default_PXEGrub2"
            edit_select(setting, :value, :select_values => katello_template_setting_values("PXEGrub2"))
          when "katello_default_user_data"
            edit_select(setting, :value, :select_values => katello_template_setting_values("user_data"))
          when "katello_default_kexec"
            edit_select(setting, :value, :select_values => katello_template_setting_values("kexec"))
          end
        end
      end

      included do
        prepend Overrides
      end

      private

      def katello_template_setting_values(name)
        templates = ProvisioningTemplate.where(:template_kind => TemplateKind.where(:name => name))
        templates.each_with_object({}) { |tmpl, hash| hash[tmpl.name] = tmpl.name }.to_json
      end
    end
  end
end
