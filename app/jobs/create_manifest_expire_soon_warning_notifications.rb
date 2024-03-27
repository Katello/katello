class CreateManifestExpireSoonWarningNotifications < ApplicationJob
  def perform
    Katello::UINotifications::Subscriptions::ManifestExpireSoonWarning.deliver!
  ensure
    self.class.set(:wait => 24.hours).perform_later
  end

  def humanized_name
    _('Subscription Manifest expiration date check')
  end
end
