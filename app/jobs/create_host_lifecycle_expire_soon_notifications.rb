class CreateHostLifecycleExpireSoonNotifications < ApplicationJob
  def perform
    Katello::UINotifications::Hosts::LifecycleExpireSoon.deliver!
  ensure
    self.class.set(:wait => 1.week).perform_later
  end

  def humanized_name
    _('Host lifecycle support expiration notification')
  end
end
