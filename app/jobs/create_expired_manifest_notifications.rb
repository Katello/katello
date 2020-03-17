class CreateExpiredManifestNotifications < ApplicationJob
  def perform
    Katello::UINotifications::Subscriptions::ManifestExpiredWarning.deliver!
  ensure
    self.class.set(:wait => 24.hours).perform_later
  end

  def humanized_name
    _('Subscription Manifest validity check')
  end
end
