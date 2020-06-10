class RemoveAuditsOfRootRepoWithContentId < ActiveRecord::Migration[6.0]
  def change
    audit_records = Audit.where(
      :auditable_type => 'Katello::RootRepository',
      :action => 'update')
    audit_records = audit_records.reject { |ar| ar.audited_changes['content_id'].nil? }
    audit_records.map(&:destroy!)
  end
end
