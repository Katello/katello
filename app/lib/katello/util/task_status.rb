module Katello
  module Util
    module TaskStatus
      # The types hash below was introduced to simplify rendering of the status of various tasks/actions.  It was
      # initially introduced to support System Event history and was later refactored, so that it may be used
      # for system groups...etc.  Refer to the job.rb and system_task.rb for examples of it's usage.
      TYPES = {
        #package tasks
        :package_install => {
          :english_name => N_("Package Install"),
          :type => :package,
          # in the event_messages structure, the first element is used for status when the action/event is scheduled
          # (e.g. System->Packages pane, the second and third are used on the Event History for singular/plural
          :event_messages => {
            :running => [N_('Installing Package...'), N_('installing package...'), N_('installing packages...')],
            :waiting => [N_('Installing Package...'), N_('installing package...'), N_('installing packages...')],
            :finished => [N_('Package Install Complete'), N_('Package installation: "%{package}" '), N_('%{package} (%{total} other packages) installed')],
            :error => [N_('Package Install Failed'), N_('Package install failed: "%{package}"'), N_('%{package} (%{total} other packages) install failed')],
            :cancelled => [N_('Package Install Canceled'), N_('%{package} package install canceled'), N_('%{package} (%{total} other packages) install canceled')],
            :timed_out => [N_('Package Install Timed Out'), N_('%{package} package install timed out'), N_('%{package} (%{total} other packages) install timed out')],
          },
          :user_message => _('Package Install scheduled by %s'),

        },
        :package_update => {
          :english_name => N_("Package Update"),
          :type => :package,
          :event_messages => {
            :running => [N_('Updating Package...'), N_('updating package...'), N_('updating packages...')],
            :waiting => [N_('Updating Package...'), N_('updating package...'), N_('updating packages...')],
            :finished => [N_('Package Update Complete'), N_('%{package} package updated'), N_('%{package} (%{total} other packages) updated')],
            :error => [N_('Package Update Failed'), N_('%{package} package update failed'), N_('%{package} (%{total} other packages) update failed')],
            :cancelled => [N_('Package Update Canceled'), N_('%{package} package update canceled'), N_('%{package} (%{total} other packages) update canceled')],
            :timed_out => [N_('Package Update Timed Out'), N_('%{package} package update timed out'), N_('%{package} (%{total} other packages) update timed out')],
          },
          :user_message => _('Package Update scheduled by %s'),
        },
        :package_remove => {
          :english_name => N_("Package Remove"),
          :type => :package,
          :event_messages => {
            :running => [N_('Removing Package...'), N_('removing package...'), N_('removing packages...')],
            :waiting => [N_('Removing Package...'), N_('removing package...'), N_('removing packages...')],
            :finished => [N_('Package Remove Complete'), N_('%{package} package removed'), N_('%{package} (%{total} other packages) removed')],
            :error => [N_('Package Remove Failed'), N_('%{package} package remove failed'), N_('%{package} (%{total} other packages) remove failed')],
            :cancelled => [N_('Package Remove Canceled'), N_('%{package} package remove canceled'), N_('%{package} (%{total} other packages) remove canceled')],
            :timed_out => [N_('Package Remove Timed Out'), N_('%{package} package remove timed out'), N_('%{package} (%{total} other packages) remove timed out')],
          },
          :user_message => _('Package Remove scheduled by %s'),
        },
        #package group tasks
        :package_group_install => {
          :english_name => N_("Package Group Install"),
          :type => :package_group,
          :event_messages => {
            :running => [N_('Installing Package Group...'), N_('installing package group...'), N_('installing package groups...')],
            :waiting => [N_('Installing Package Group...'), N_('installing package group...'), N_('installing package groups...')],
            :finished => [N_('Package Group Install Complete'), N_('%{group} package group installed'), N_('%{group} (%{total} other package groups) installed')],
            :error => [N_('Package Group Install Failed'), N_('%{group} package group install failed'), N_('%{group} (%{total} other package groups) install failed')],
            :cancelled => [N_('Package Group Install Canceled'), N_('%{group} package group install canceled'), N_('%{group} (%{total} other package groups) install canceled')],
            :timed_out => [N_('Package Group Install Timed Out'), N_('%{group} package group install timed out'), N_('%{group} (%{total} other package groups) install timed out')],
          },
          :user_message => _('Package Group Install scheduled by %s'),
        },
        :package_group_update => {
          :english_name => N_("Package Group Update"),
          :type => :package_group,
          :event_messages => {
            :running => [N_('Updating package group...'), N_('updating package group...'), N_('updating package groups...')],
            :waiting => [N_('Updating package group...'), N_('updating package group...'), N_('updating package groups...')],
            :finished => [N_('Package group update complete'), N_('%{group} package group updated'), N_('%{group} (%{total} other package groups) updated')],
            :error => [N_('Package group update failed'), N_('%{group} package group update failed'), N_('%{group} (%{total} other package groups) update failed')],
            :cancelled => [N_('Package group update canceled'), N_('%{group} package group update canceled'), N_('%{group} (%{total} other package groups) update canceled')],
            :timed_out => [N_('Package group update timed out'), N_('%{group} package group update timed out'), N_('%{group} (%{total} other package groups) update timed out')],

          },
          :user_message => _('Package Group Update scheduled by %s'),
        },
        :package_group_remove => {
          :english_name => N_("Package Group Remove"),
          :type => :package_group,
          :event_messages => {
            :running => [N_('Removing Package Group...'), N_('removing package group...'), N_('removing package groups...')],
            :waiting => [N_('Removing Package Group...'), N_('removing package group...'), N_('removing package groups...')],
            :finished => [N_('Package Group Remove Complete'), N_('%{group} package group removed'), N_('%{group} (%{total} other package groups) removed')],
            :error => [N_('Package Group Remove Failed'), N_('%{group} package group remove failed'), N_('%{group} (%{total} other package groups) remove failed')],
            :cancelled => [N_('Package Group Remove Canceled'), N_('%{group} package group remove canceled'), N_('%{group} (%{total} other package groups) remove canceled')],
            :timed_out => [N_('Package Group Remove Timed Out'), N_('%{group} package group remove timed out'), N_('%{group} (%{total} other package groups) remove timed out')],

          },
          :user_message => _('Package Group Remove scheduled by %s'),
        },
        :errata_install => {
          :english_name => N_("Errata Install"),
          :type => :errata,
          :event_messages => {
            :running => [N_('Installing Erratum...'), N_('installing erratum...'), N_('installing errata...')],
            :waiting => [N_('Installing Erratum...'), N_('installing erratum...'), N_('installing errata...')],
            :finished => [N_('Erratum Install Complete'), N_('%{errata} erratum installed'), N_('%{errata} (%{total} other errata) installed')],
            :error => [N_('Erratum Install Failed'), N_('%{errata} erratum install failed'), N_('%{errata} (%{total} other errata) install failed')],
            :cancelled => [N_('Erratum Install Canceled'), N_('%{errata} erratum install canceled'), N_('%{errata} (%{total} other errata) install canceled')],
            :timed_out => [N_('Erratum Install Timed Out'), N_('%{errata} erratum install timed out'), N_('%{errata} (%{total} other errata) install timed out')],
          },
          :user_message => _('Errata Install scheduled by %s'),
        },
        :candlepin_event => {
          :english_name => N_("Candlepin Event"),
          :type => :candlepin_event,
          :event_messages => {
          },
          :user_message => nil,
        },
        :content_view_publish => {
          :english_name => N_("content view publish"),
          :type => :content_view_publish,
        },
        :content_view_node_publish => {
          :english_name => N_("content view node publish"),
          :type => :content_view_node_publish,
        },
        :content_view_refresh => {
          :english_name => N_("content view refresh"),
          :type => :content_view_refresh,
        },
      }.with_indifferent_access

      TYPES.each_pair do |_name, value|
        value[:name] = _(value[:english_name])
      end
    end
  end
end
