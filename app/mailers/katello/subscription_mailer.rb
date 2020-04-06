module Katello
  class SubscriptionMailer < ApplicationMailer
    after_action :prevent_sending_blank_report

    def subscription_expiry(options)
      user = ::User.find(options[:user])
      days_from_now = options[:query]

      ::User.as(user.login) do
        @pools = Katello::Pool.readable.expiring_in_days(days_from_now)
      end

      set_locale_for(user) do
        mail(:to => user.mail, :subject => _("You have subscriptions expiring within #{days_from_now} days"))
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
