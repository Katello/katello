class RemoveContentCountsIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :smart_proxies, :content_counts
  end
end
