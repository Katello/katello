require 'katello_test_helper'

module Katello
  class ErrataMailerTest < ActiveSupport::TestCase
    def setup
      @user = User.current = User.find(users('admin').id)

      FactoryBot.create(:mail_notification,
                         :name => 'host_errata_advisory',
                         :description => 'A summary of available and applicable errata for your hosts',
                         :mailer => 'Katello::ErrataMailer',
                         :method => 'host_errata',
                         :subscription_type => 'report')

      FactoryBot.create(:mail_notification,
                         :name => 'sync_errata',
                         :description => 'A summary of new errata after a repository is synchronized',
                         :mailer => 'Katello::ErrataMailer',
                         :method => 'sync_errata',
                         :subscription_type => 'alert')

      FactoryBot.create(:mail_notification,
                         :name => 'promote_errata',
                         :description => 'A post-promotion summary of hosts with installable errata',
                         :mailer => 'Katello::ErrataMailer',
                         :method => 'promote_errata',
                         :subscription_type => 'alert')

      @user.mail_notifications << MailNotification[:host_errata_advisory]
      @user.mail_notifications << MailNotification[:sync_errata]
      @user.mail_notifications << MailNotification[:promote_errata]

      @errata_host = hosts(:one)
    end

    def test_host_errata
      ActionMailer::Base.deliveries = []
      @user.user_mail_notifications.first.deliver
      email = ActionMailer::Base.deliveries.first
      assert email.body.encoded.include? @errata_host.name
      assert email.body.encoded.include? "http://foreman.some.host.fqdn/content_hosts/#{@errata_host.id}/errata"
    end

    def test_sync_errata
      ActionMailer::Base.deliveries = []
      repo = katello_repositories(:rhel_6_x86_64)
      errata = ::Katello::Erratum.where(:id => repo.repository_errata.where('katello_repository_errata.updated_at > ?', 10.years.ago).pluck(:erratum_id))
      MailNotification[:sync_errata].deliver(:users => [@user], :repo => repo, :errata => errata)
      email = ActionMailer::Base.deliveries.first
      assert email.body.encoded.include? katello_errata(:security).errata_id
    end

    def test_promote_errata
      view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)
      @errata_host.content_facet.bound_repositories = [view_repo]
      @errata_host.content_facet.content_view = katello_content_views(:acme_default)
      @errata_host.content_facet.save!

      ActionMailer::Base.deliveries = []
      MailNotification[:promote_errata].deliver(:users => [@user], :content_view => @errata_host.content_facet.content_view,
                                                        :environment => @errata_host.content_facet.lifecycle_environment)
      email = ActionMailer::Base.deliveries.first
      assert email.body.encoded.include? 'RHSA-1999-1231'
    end
  end
end
