class EncryptPasswordInAudit < ActiveRecord::Migration[6.0]
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

  def encrypt_upstream_password_for_root_repository_audits
    ::Katello::RootRepository.all.each do |repository|
      repository.audits.each do |audit|
        if audit.audited_changes.key? "upstream_password"
          encrypt_password_for_audit(audit)
        end
      end
    end
  end

  def up
    encrypt_upstream_password_for_root_repository_audits
  end

  def down
    # Do nothing
  end
end
