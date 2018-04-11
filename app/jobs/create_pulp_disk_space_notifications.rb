class CreatePulpDiskSpaceNotifications < ApplicationJob
  after_perform do
    self.class.set(:wait => 12.hours).perform_later
  end

  def perform
    Katello::UINotifications::Pulp::ProxyDiskSpace.deliver!
  end

  def humanized_name
    _('Pulp disk space notification')
  end
end
