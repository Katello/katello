class CreatePulpDiskSpaceNotifications < ApplicationJob
  def perform
    Katello::UINotifications::Pulp::ProxyDiskSpace.deliver!
  ensure
    self.class.set(:wait => 12.hours).perform_later
  end

  def humanized_name
    _('Pulp disk space notification')
  end
end
