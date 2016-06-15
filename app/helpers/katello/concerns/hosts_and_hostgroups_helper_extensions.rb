module Katello
  module Concerns
    module HostsAndHostgroupsHelperExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :puppet_environment_field, :katello
      end

      def puppet_environment_field_with_katello(form, environments_choice, select_options = {}, html_options = {})
        html_options.merge!(
          :label => _("Puppet Environment"),
          'data-content_puppet_match' => (@host || @hostgroup).new_record? || (@host || @hostgroup).content_and_puppet_match?,
          :help_inline => link_to(_("Reset Puppet Environment to match selected Content View"), '#', :id => 'reset_puppet_environment'))
        puppet_environment_field_without_katello(form, environments_choice, select_options, html_options)
      end
    end
  end
end
