class RemoveKatelloFromNotificationName < ActiveRecord::Migration
  class FakeMailNotification < ApplicationRecord
    self.table_name = 'mail_notifications'
  end

  def up
    FakeMailNotification.all.each do |notification|
      if notification_names.keys.include?(notification.name)
        new_name = notification_names[notification.name]
        FakeMailNotification.where(:name => new_name).destroy_all
        notification.name = new_name
        notification.save!
      end
    end
  end

  private

  def notification_names
    {
      :katello_promote_errata => 'promote_errata',
      :katello_sync_errata => 'sync_errata',
      :katello_host_advisory => 'host_errata_advisory'
    }.with_indifferent_access
  end
end
