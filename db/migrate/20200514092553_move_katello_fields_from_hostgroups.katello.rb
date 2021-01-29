class MoveKatelloFieldsFromHostgroups < ActiveRecord::Migration[6.0]
  def up
    if User.unscoped.where(login: User::ANONYMOUS_ADMIN).exists?
      User.as_anonymous_admin do
        copy_data_from_hostgroup
      end
    end

    change_table :hostgroups do |table|
      table.remove(
        :content_source_id,
        :kickstart_repository_id,
        :content_view_id,
        :lifecycle_environment_id
      )
    end
  end

  def down
    change_table :hostgroups do |t|
      t.column :kickstart_repository_id, :integer, :null => true
      t.column :content_source_id, :integer, :null => true
      t.column :content_view_id, :integer, :null => true
      t.column :lifecycle_environment_id, :integer, :null => true
    end
  end

  def copy_data_from_hostgroup
    hg_table = ::Hostgroup.arel_table
    hostgroups = ::Hostgroup.unscoped.where(
           hg_table[:content_source_id].eq(nil)
      .and(hg_table[:kickstart_repository_id].eq(nil))
      .and(hg_table[:content_view_id].eq(nil))
      .and(hg_table[:lifecycle_environment_id].eq(nil))
      .not)
    hostgroups.in_batches do |batch|
      batch.pluck(
        :id,
        :content_source_id,
        :kickstart_repository_id,
        :content_view_id,
        :lifecycle_environment_id
      ).each do |hostgroup_id, content_source_id, kickstart_repository_id, content_view_id, lifecycle_environment_id|
        content_facet = ::Katello::Hostgroup::ContentFacet.find_or_create_by(hostgroup_id: hostgroup_id)
        content_facet.content_source_id = content_source_id
        content_facet.kickstart_repository_id = kickstart_repository_id
        content_facet.content_view_id = content_view_id
        content_facet.lifecycle_environment_id = lifecycle_environment_id
        unless content_facet.save
          Rails.logger.warn("Unable to save content facet hostgroup for #{content_facet.inspect} ")
          Rails.logger.warn(content_facet.errors.full_messages.join("\n"))
        end
      end
    end
  end
end
