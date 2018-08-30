class SendExpireSoonNotifications < ApplicationJob
  def perform
    Katello::UINotifications::Subscriptions::ExpireSoon.deliver!
  ensure
    self.class.set(:wait => 12.hours).perform_later
  end

  def humanized_name
    _('Subscription expiration notification')
  end
end
