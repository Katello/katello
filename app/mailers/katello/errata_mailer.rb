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

module Katello
  class ErrataMailer < ApplicationMailer
    helper :'katello/errata_mailer'

    def host_errata(options)
      return unless (user = User.find(options[:user]))

      @content_hosts = Katello::System.authorized_as(user, :view_content_hosts).reject { |host| host.applicable_errata.empty? }

      set_locale_for user

      mail(:to        => user.mail,
           :subject   => _("Katello Host Advisory"),
           :date      => Time.zone.now)
    end

    def sync_errata(options)
      return unless (@repo = Katello::Repository.find(options[:repo])) && (last_updated = options[:last_updated].to_datetime)

      recipients = User.all.select do |user|
        user.receives?(:katello_sync_errata) && user.can?(:view_products, @repo.product)
      end

      fail Errors::NotFound, N_("No recipients found for %s sync report") % @repo.name unless recipients.any?

      all_errata = Katello::Erratum.where(:id => @repo.repository_errata.where('katello_repository_errata.updated_at > ?', last_updated).pluck(:erratum_id))

      @errata_counts = errata_counts(all_errata)
      @errata = all_errata.take(100).group_by(&:errata_type)

      group_mail(recipients, :subject => (_("Katello Sync Summary for %s") % @repo.name))
    end

    def promote_errata(options)
      return unless (content_view = Katello::ContentView.find(options[:content_view])) &&
        (environment = Katello::KTEnvironment.find(options[:environment]))

      recipients = User.all.select do |user|
        user.receives?(:katello_promote_errata) && user.can?(:view_content_views, content_view)
      end

      fail Errors::NotFound, N_("No recipients found for %s promotion summary") % content_view.name unless recipients.any?

      @content_view = content_view
      @environment = environment

      @content_hosts = Katello::System.where(:environment_id => environment.id, :content_view_id => content_view.id)

      group_mail(recipients, :subject => (_("Katello Promotion Summary for %{content_view}") % {:content_view => content_view.name}))
    end

    private

    # FIXME: Remove in Katello 2.2/Foreman 1.8, which has this @user fix in #8348
    def group_mail(users, options)
      mails = users.map do |user|
        @user = user
        set_locale_for user
        mail(options.merge(:to => user.mail)) unless user.mail.blank?
      end
      GroupMail.new(mails.compact)
    end

    def errata_counts(errata)
      counts = {:total => errata.count}
      counts.merge(Hash[[:security, :bugfix, :enhancement].collect do |errata_type|
        [errata_type, errata.send(errata_type).count]
      end])
    end
  end
end
