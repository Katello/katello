class RepositoryChangeIndex < ActiveRecord::Migration
  def self.up
    remove_index(:repositories, :column => [:label, :environment_product_id])
    add_index(:repositories, [:label, :content_view_version_id, :environment_product_id],
              :unique => true, :name => 'repositories_l_cvvi_epi')
  end

  def self.down
    remove_index(:repositories, :name => 'repositories_l_cvi_epi')
    add_index(:repositories, [:label, :environment_product_id], :unique => true)
  end
end
