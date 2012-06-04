#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  module TaskStatusUtil

    # The types hash below was introduced to simplify rendering of the status of various tasks/actions.  It was
    # initially introduced to support System Event history and was later refactored, so that it may be used
    # for system groups...etc.  Refer to the job.rb and system_task.rb for examples of it's usage.
    TYPES = {
        #package tasks
       :package_install => {
            :english_name =>N_("Package Install"),
            :type => :package,
            # in the event_messages structure, the first element is used for status when the action/event is scheduled
            # (e.g. System->Packages pane, the second and third are used on the Event History for singular/plural
            :event_messages => {
                :running => [N_('Installing Package...'), N_('installing package...'), N_('installing packages...')],
                :waiting => [N_('Installing Package...'), N_('installing package...'), N_('installing packages...')],
                :finished => [N_('Package Install Complete'), N_('%s package install'), N_('%s (%s other packages) install.')],
                :error=> [N_('Package Install Failed'), N_('%s package install failed'), N_('%s (%s other packages) install failed')],
                :cancelled => [N_('Package Install Cancelled'), N_('%s package install cancelled'), N_('%s (%s other packages) install cancelled')],
                :timed_out =>[N_('Package Install Timed Out'), N_('%s package install timed out'), N_('%s (%s other packages) install timed out')],
            },
           :user_message => _('Package Install scheduled by %s')

        },
        :package_update => {
            :english_name =>N_("Package Update"),
            :type => :package,
            :event_messages => {
                :running => [N_('Updating Package...'), N_('updating package...'), N_('updating packages...')],
                :waiting => [N_('Updating Package...'), N_('updating package...'), N_('updating packages...')],
                :finished =>[N_('Package Update Complete'), N_('%s package update'), N_('%s (%s other packages) update')],
                :error => [N_('Package Update Failed'), N_('%s package update failed'), N_('%s (%s other packages) update failed')],
                :cancelled =>[N_('Package Update Cancelled'), N_('%s package update cancelled'), N_('%s (%s other packages) update cancelled')],
                :timed_out =>[N_('Package Update Timed Out'), N_('%s package update timed out'), N_('%s (%s other packages) update timed out')],
            },
            :user_message => _('Package Update scheduled by %s')
        },
        :package_remove => {
            :english_name =>N_("Package Remove"),
            :type => :package,
            :event_messages => {
                :running => [N_('Removing Package...'), N_('removing package...'), N_('removing packages...')],
                :waiting => [N_('Removing Package...'), N_('removing package...'), N_('removing packages...')],
                :finished => [N_('Package Remove Complete'), N_('%s package removal'), N_('%s (%s other packages) removal')],
                :error => [N_('Package Remove Failed'), N_('%s package remove failed'), N_('%s (%s other packages) remove failed')],
                :cancelled => [N_('Package Remove Cancelled'), N_('%s package remove cancelled'), N_('%s (%s other packages) remove cancelled')],
                :timed_out => [N_('Package Remove Timed Out'), N_('%s package remove timed out'), N_('%s (%s other packages) remove timed out')],
            },
            :user_message => _('Package Remove scheduled by %s')
        },
        #package group tasks
        :package_group_install => {
            :english_name =>N_("Package Group Install"),
            :type => :package_group,
            :event_messages => {
                :running => [N_('Installing Package Group...'), N_('installing package group...'), N_('installing package groups...')],
                :waiting => [N_('Installing Package Group...'), N_('installing package group...'), N_('installing package groups...')],
                :finished => [N_('Package Group Install Complete'), N_('%s package group install'), N_('%s (%s other package groups) install')],
                :error=> [N_('Package Group Install Failed'), N_('%s package group install failed'), N_('%s (%s other package groups) install failed')],
                :cancelled => [N_('Package Group Install Cancelled'), N_('%s package group install cancelled'), N_('%s (%s other package groups) install cancelled')],
                :timed_out =>[N_('Package Group Install Timed Out'), N_('%s package group install timed out'), N_('%s (%s other package groups) install timed out')],
            },
            :user_message => _('Package Group Install scheduled by %s')
        },
        :package_group_update => {
            :english_name =>N_("Package Group Update"),
            :type => :package_group,
            :event_messages => {
                :running => [N_('updating package group...'), N_('updating package group...'), N_('updating package groups...')],
                :waiting => [N_('updating package group...'), N_('updating package group...'), N_('updating package groups...')],
                :finished =>[N_('package group update complete'), N_('%s package group update'), N_('%s (%s other package groups) update')],
                :error => [N_('package group update failed'), N_('%s package group update failed'), N_('%s (%s other package groups) update failed')],
                :cancelled =>[N_('package group update cancelled'), N_('%s package group update cancelled'), N_('%s (%s other package groups) update cancelled')],
                :timed_out =>[N_('package group update timed out'), N_('%s package group update timed out'), N_('%s (%s other package groups) update timed out')],

            },
            :user_message => _('Package Group Update scheduled by %s')
        },
        :package_group_remove => {
            :english_name =>N_("Package Group Remove"),
            :type => :package_group,
            :event_messages => {
                :running => [N_('Removing Package Group...'), N_('removing package group...'), N_('removing package groups...')],
                :waiting => [N_('Removing Package Group...'), N_('removing package group...'), N_('removing package groups...')],
                :finished => [N_('Package Group Remove Complete'), N_('%s package group removal'), N_('%s (%s other package groups) removal')],
                :error => [N_('Package Group Remove Failed'), N_('%s package group remove failed'), N_('%s (%s other package groups) remove failed')],
                :cancelled => [N_('Package Group Remove Cancelled'), N_('%s package group remove cancelled'), N_('%s (%s other package groups) remove cancelled')],
                :timed_out => [N_('Package Group Remove Timed Out'), N_('%s package group remove timed out'), N_('%s (%s other package groups) remove timed out')],

            },
            :user_message => _('Package Group Remove scheduled by %s')
        },
        :errata_install => {
            :english_name =>N_("Errata Install"),
            :type => :errata,
            :event_messages => {
                :running => [N_('Installing Erratum...'), N_('installing erratum...'), N_('installing errata...')],
                :waiting => [N_('Installing Erratum...'), N_('installing erratum...'), N_('installing errata...')],
                :finished => [N_('Erratum Install Complete'), N_('%s erratum install'), N_('%s (%s other errata) install.')],
                :error=> [N_('Erratum Install Failed'), N_('%s erratum install failed'), N_('%s (%s other errata) install failed')],
                :cancelled => [N_('Erratum Install Cancelled'), N_('%s erratum install cancelled'), N_('%s (%s other errata) install cancelled')],
                :timed_out =>[N_('Erratum Install Timed Out'), N_('%s erratum install timed out'), N_('%s (%s other errata) install timed out')],
            },
           :user_message => _('Errata Install scheduled by %s')
        },
        :candlepin_event => {
            :english_name =>N_("Candlepin Event"),
            :type => :candlepin_event,
            :event_messages => {
            },
            :user_message => nil
        },
    }.with_indifferent_access

    TYPES.each_pair do |name, value|
      value[:name] = _(value[:english_name])
    end

  end
end
