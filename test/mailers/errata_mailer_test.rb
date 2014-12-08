#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
  class ErrataMailerTest < ActiveSupport::TestCase
    def setup
      @user = User.current = User.find(users('admin'))

      FactoryGirl.create(:mail_notification,
                         :name => 'katello_host_advisory',
                         :description => 'A summary of available and applicable errata for your hosts',
                         :mailer => 'Katello::ErrataMailer',
                         :method => 'host_errata',
                         :subscription_type => 'report')

      FactoryGirl.create(:mail_notification,
                         :name => 'katello_sync_errata',
                         :description => 'A summary of new errata after a repository is synchronized',
                         :mailer => 'Katello::ErrataMailer',
                         :method => 'sync_errata',
                         :subscription_type => 'alert')

      FactoryGirl.create(:mail_notification,
                         :name => 'katello_promote_errata',
                         :description => 'A post-promotion summary of hosts with available errata',
                         :mailer => 'Katello::ErrataMailer',
                         :method => 'promote_errata',
                         :subscription_type => 'alert')

      @user.mail_notifications << MailNotification[:katello_host_advisory]
      @user.mail_notifications << MailNotification[:katello_sync_errata]
      @user.mail_notifications << MailNotification[:katello_promote_errata]

      @errata_system = katello_systems(:errata_server)
    end

    def test_host_errata
      ActionMailer::Base.deliveries = []
      @user.user_mail_notifications.first.deliver
      email = ActionMailer::Base.deliveries.first
      assert email.body.encoded.include? @errata_system.name
      assert email.body.encoded.include? 'http://foreman.some.host.fqdn/content_hosts/010E99C0-3276-11E2-81C1-0800200Czzzzz/errata'
    end

    def test_sync_errata
      ActionMailer::Base.deliveries = []
      repo = katello_repositories(:rhel_6_x86_64)
      last_updated = 10.years.ago
      MailNotification[:katello_sync_errata].deliver(:repo => repo.id, :last_updated => last_updated.to_s)
      email = ActionMailer::Base.deliveries.first
      assert email.body.encoded.include? katello_errata(:security).errata_id
    end

    def test_promote_errata
      ActionMailer::Base.deliveries = []
      MailNotification[:katello_promote_errata].deliver(:content_view => @errata_system.content_view_id, :environment => @errata_system.environment_id)
      email = ActionMailer::Base.deliveries.first
      assert email.body.encoded.include? 'RHSA-1999-1231'
    end
  end
end
