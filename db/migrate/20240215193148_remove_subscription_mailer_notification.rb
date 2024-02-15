class RemoveSubscriptionMailerNotification < ActiveRecord::Migration[6.1]
  def change
    subscriptions_expiring_soon_mailer = MailNotification.find_by(name: "subscriptions_expiring_soon")
    subscriptions_expiring_soon_mailer&.delete
  end
end
