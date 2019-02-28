class UpdateServiceRestartFeature < ActiveRecord::Migration[5.2]
  def up
    if Katello.with_remote_execution?
      ansible_template = JobTemplate.unscoped.find_by(name: 'Restart Services - Katello Ansible Default')
      feature = RemoteExecutionFeature.find_by(label: :katello_service_restart)
      if feature
        feature.job_template = ansible_template
        feature.save!
      end
    end
  end

  def down
    if Katello.with_remote_execution?
      ssh_template = JobTemplate.unscoped.find_by(name: 'Restart Services - Katello SSH Default')
      feature = RemoteExecutionFeature.find_by(label: :katello_service_restart)
      if feature
        feature.job_template = ssh_template
        feature.save!
      end
    end
  end
end
