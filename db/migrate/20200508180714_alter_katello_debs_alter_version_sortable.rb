require 'fx'

class AlterKatelloDebsAlterVersionSortable < ActiveRecord::Migration[6.0]
  class Katello::Deb < Katello::Model
  end

  def up
    enable_extension 'debversion'
    change_column :katello_debs, :version_sortable, :debversion
    Katello::Deb.update_all('version_sortable = version')
  end

  def down
    change_column :katello_debs, :version_sortable, :string
    disable_extension 'debversion'
  end
end
