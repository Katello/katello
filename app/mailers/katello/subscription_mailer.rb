module Katello
  class SubscriptionMailer < ApplicationMailer
    helper :'katello/subscription_mailer'
    after_action :prevent_sending_blank_report
    include SubscriptionMailerHelper

    def subscription_expiry(options)
      user = ::User.find(options[:user])
      days_from_now = options[:query]

      ::User.as(user.login) do
        @pools = Katello::Pool.readable.expiring_in_days(days_from_now)
      end

      start_report_task(days_from_now)
      @report_url = report_url
      @report_link = report_link

      set_locale_for(user) do
        mail(:to => user.mail, :subject => _("You have subscriptions expiring within %s days") % days_from_now)
      end
    end

    private

    def prevent_sending_blank_report
      if @pools.blank?
        mail.perform_deliveries = false
      end
    end
  end
end
