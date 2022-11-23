class RemovePulpDockerRegistryPortSetting < ActiveRecord::Migration[6.1]
  def change
    Setting.where(name: 'pulp_docker_registry_port').destroy_all
  end
end
