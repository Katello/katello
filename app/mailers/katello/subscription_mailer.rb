module Katello
  class SubscriptionMailer < ApplicationMailer
    after_action :prevent_sending_blank_report

    def subscription_expiry(options)
      user = ::User.find(options[:user])
      ::User.as(user.login) do
        @pools = Katello::Pool.readable.expiring_in_days(65)
      end

      set_locale_for(user) do
        mail(:to => user.mail, :subject => _("Subscriptions expiring soon"))
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
