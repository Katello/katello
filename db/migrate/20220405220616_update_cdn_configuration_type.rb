class UpdateCdnConfigurationType < ActiveRecord::Migration[6.0]
  class FakeCdnConfiguration < Katello::Model
    self.table_name = 'katello_cdn_configurations'
    self.inheritance_column = nil
  end

  def change
    FakeCdnConfiguration.where(type: 'upstream_server').update_all(type: 'network_sync')
    FakeCdnConfiguration.where(type: 'airgapped').update_all(type: 'export_sync')
  end
end
