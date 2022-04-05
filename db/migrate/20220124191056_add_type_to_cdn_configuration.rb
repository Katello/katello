class AddTypeToCdnConfiguration < ActiveRecord::Migration[6.0]
  class FakeCdnConfiguration < Katello::Model
    self.table_name = 'katello_cdn_configurations'
    self.inheritance_column = nil
  end

  def change
    add_index :katello_cdn_configurations, :organization_id, unique: true
    add_column :katello_cdn_configurations, :type, :string, default: 'redhat_cdn'

    FakeCdnConfiguration.reset_column_information
    FakeCdnConfiguration.all.each do |config|
      unless config.username.blank? ||
             config.password.blank? ||
             config.upstream_organization_label.blank? ||
             config.ssl_ca_credential_id.blank?
        config.update!(type: 'upstream_server')
      end
    end
  end
end
