module Katello
  module Concerns
    module HostsAndHostgroupsHelperExtensions
      extend ActiveSupport::Concern

      module Overrides
        def puppet_environment_field(form, environments_choice, select_options = {}, html_options = {})
          html_options.merge!(
            :label => _("Puppet Environment"),
            'data-content_puppet_match' => (@host || @hostgroup).new_record? || (@host || @hostgroup).content_and_puppet_match?,
            :help_inline => link_to(_("Reset Puppet Environment"), '#', :id => 'reset_puppet_environment'))
          super(form, environments_choice, select_options, html_options)
        end
      end
      included do
        prepend Overrides
      end
    end
  end
end
