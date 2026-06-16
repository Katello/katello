class AddUniqueIndexToKatelloHostCollectionHosts < ActiveRecord::Migration[6.1]
  def up
    remove_duplicate_host_collection_hosts

    add_index :katello_host_collection_hosts,
              [:host_collection_id, :host_id],
              :unique => true,
              :name => :index_katello_host_collection_hosts_on_collection_and_host
  end

  def down
    remove_index :katello_host_collection_hosts,
                 :name => :index_katello_host_collection_hosts_on_collection_and_host
  end

  private

  def remove_duplicate_host_collection_hosts
    execute(<<~SQL.squish)
      DELETE FROM katello_host_collection_hosts
      WHERE id IN (
        SELECT id
        FROM (
          SELECT id,
                 ROW_NUMBER() OVER (PARTITION BY host_collection_id, host_id ORDER BY id) AS duplicate_rank
          FROM katello_host_collection_hosts
        ) duplicate_rows
        WHERE duplicate_rank > 1
      )
    SQL
  end
end
