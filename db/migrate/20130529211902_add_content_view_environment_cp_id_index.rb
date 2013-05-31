class AddContentViewEnvironmentCpIdIndex < ActiveRecord::Migration
  def up
    cves = {}
    data = ActiveRecord::Base.connection.select_all( "SELECT id, cp_id, environment_id, content_view_id FROM content_view_environments")

    data.each do |cve|
      cves[cve['cp_id']] ||= []
      cves[cve['cp_id']] << cve['id']
    end

    cves.each_pair do |cp_id, ids|
      if ids.size > 1
        to_delete = ids.slice(1, ids.size-1)
        to_delete.each{|id| ActiveRecord::Base.connection.delete("DELETE from content_view_environments where id = #{id}")}
      end
    end

    add_index(:content_view_environments, [:environment_id, :content_view_id], :unique=>true, :name=>:index_cve_eid_cv_id)
    add_index(:content_view_environments, [:cp_id], :unique=>true, :name=>:index_cve_cp_id)
  end

  def down
    remove_index(:content_view_environments, :name=>:index_cve_eid_cv_id)
    remove_index( :content_view_environments, :name=>:index_cve_cp_id)
  end
end
