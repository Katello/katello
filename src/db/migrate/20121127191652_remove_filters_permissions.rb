class RemoveFiltersPermissions < ActiveRecord::Migration
  def self.up
    change_table(:permissions) do |t|
      execute("delete from permissions where resource_type_id in (select id from resource_types where name='filters')")
      execute("delete from resource_types where name='filters'")
    end
  end

  def self.down
    # deleted filters no way to roll back
  end
end
