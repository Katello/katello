class RemovePackageGroupRemoteExecutionActions < ActiveRecord::Migration[6.1]
  LABELS = %w[katello_group_install katello_group_update katello_group_remove].freeze
  TEMPLATE_NAMES = {
    'script' => [
      'Install Group - Katello Script Default',
      'Update Group - Katello Script Default',
      'Remove Group - Katello Script Default',
    ],
    'Ansible' => [
      'Install Group - Katello Ansible Default',
      'Update Group - Katello Ansible Default',
      'Remove Group - Katello Ansible Default',
    ],
  }.freeze
  DISABLED_BODY = "<% render_error(N_('Remote execution package-group actions have been removed.')) %>".freeze

  def up
    connection.transaction(:requires_new => true) do
      features = ::RemoteExecutionFeature.where(:label => LABELS)

      # Clear the FK before deleting features; retain job invocation history.
      ::JobInvocation.unscoped.where(:remote_execution_feature_id => features.select(:id))
                     .update_all(:remote_execution_feature_id => nil)
      features.delete_all

      # Preserve template/input IDs and invocation history. Hide the retired defaults
      # from standalone selection and reject direct-ID or nested rendering.
      TEMPLATE_NAMES.each do |provider, names|
        ::JobTemplate.unscoped.where(:default => true, :provider_type => provider, :name => names)
                     .update_all(:snippet => true, :template => DISABLED_BODY, :updated_at => Time.current)
      end
    end
  rescue StandardError => e
    message = "Package-group remote execution cleanup failed; " \
              "manual cleanup may be required. " \
              "#{e.class}: #{e.message}"

    say "WARNING: #{message}"
    Rails.logger.warn(message)
  end

  def down
    fail ActiveRecord::IrreversibleMigration, 'Restore the pre-upgrade database backup to restore removed actions'
  end
end
