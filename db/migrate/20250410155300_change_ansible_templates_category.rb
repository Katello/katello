class ChangeAnsibleTemplatesCategory < ActiveRecord::Migration[7.0]
  TEMPLATES = [
    'Install errata by search query - Katello Ansible Default',
    'Install packages by search query - Katello Ansible Default',
    'Remove packages by search query - Katello Ansible Default',
    'Update packages by search query - Katello Ansible Default',
  ].freeze

  def up
    change_category('Katello', 'Katello via Ansible')
  end

  def down
    change_category('Katello via Ansible', 'Katello')
  end

  private

  def change_category(from, to)
    ::Template.where(type: 'JobTemplate', provider_type: 'Ansible', job_category: from, name: TEMPLATES).update_all(job_category: to)
  end
end
