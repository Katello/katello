class FixChangesetDistributionUniqueIndex < ActiveRecord::Migration
  def self.up
    remove_index(:changeset_distributions, :name =>"index_cs_distro_distro_id_cs_id")
    add_index(:changeset_distributions, [:distribution_id, :changeset_id, :product_id], :name => "index_cs_distro_distro_id_cs_id_p_id", :unique => true)
  end

  def self.down
    remove_index(:changeset_distributions, :name =>"index_cs_distro_distro_id_cs_id_p_id")
    add_index(:changeset_distributions, [:distribution_id, :changeset_id], :name => "index_cs_distro_distro_id_cs_id", :unique => true)
  end
end
