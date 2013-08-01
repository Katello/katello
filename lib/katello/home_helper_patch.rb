module Katello
  module HomeHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :setting_options, :content_link
      end
    end

    module InstanceMethods
      # Adds a content link to the More menu
      def setting_options_with_content_link
        choices = setting_options_without_content_link
        content_group =
            [[_('Providers'),    :"katello/providers"],
             [_('Sync Management'),  :"katello/sync_management"]
            ]
        choices.insert(3,[:divider],[:group, _("Content"), content_group])
      end
    end
  end
end
