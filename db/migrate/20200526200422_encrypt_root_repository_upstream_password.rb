class EncryptRootRepositoryUpstreamPassword < ActiveRecord::Migration[6.0]
  def encrypt_password_for_audit(audit)
    changes = audit.audited_changes
    name = :upstream_password.to_s
    change = changes[name]

    if change.is_a? Array
      changes[name] = change.map { |_| AuditExtensions::REDACTED }
    elsif change
      changes[name] = AuditExtensions::REDACTED
    end

    audit.save!
  end

  def encrypt_upstream_password_changes_for_audits(root_repository)
    root_repository.audits.each do |audit|
      if audit.audited_changes.key? "upstream_password"
        encrypt_password_for_audit(audit)
      end
    end
  end

  def modify_root_repository_upstream_password(action)
    encryptable_field = :upstream_password

    ::Katello::RootRepository.all.each do |root_repository|
      original_upstream_password = root_repository.read_attribute(encryptable_field)
      root_repository.update_column(encryptable_field,
        root_repository.send("#{action}_field", original_upstream_password))

      if action == :encrypt
        encrypt_upstream_password_changes_for_audits(root_repository)
      end
    end
  end

  def up
    modify_root_repository_upstream_password(:encrypt)
  end

  def down
    modify_root_repository_upstream_password(:decrypt)
  end
end
