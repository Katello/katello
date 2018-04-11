class SendExpireSoonNotifications < ApplicationJob
  after_perform do
    self.class.set(:wait => 12.hours).perform_later
  end

  def perform
    Katello::UINotifications::Subscriptions::ExpireSoon.deliver!
  end

  def humanized_name
    _('Subscription expiration notification')
  end
end
