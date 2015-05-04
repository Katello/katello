class AddContentHostIdToSmartProxy < ActiveRecord::Migration
  class SmartProxy < ActiveRecord::Base
  end

  class Katello::System < ActiveRecord::Base
  end

  def change
    add_column :smart_proxies, :content_host_id, :integer
    add_foreign_key :smart_proxies, :katello_systems, :column => "content_host_id"

    SmartProxy.all.each do |proxy|
      content_host = ::Katello::System.where(:name => proxy.name).order("created_at DESC").first

      proxy.content_host_id = content_host.id
      proxy.save!
    end
  end
end
