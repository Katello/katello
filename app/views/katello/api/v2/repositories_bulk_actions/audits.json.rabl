object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  attributes :id, :auditable_id, :auditable_name, :auditable_type, :action, :audited_changes

  attributes :user_id, :user_type, :user_name, :version, :comment, :associated_id, :associated_type,
             :remote_address, :associated_name, :created_at, :updated_at
end
