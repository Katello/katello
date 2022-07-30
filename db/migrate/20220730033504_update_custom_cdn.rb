class UpdateCustomCdn < ActiveRecord::Migration[6.1]
  class FakeCdnConfiguration < Katello::Model
    self.table_name = 'katello_cdn_configurations'
    self.inheritance_column = nil
  end

  def change
    FakeCdnConfiguration.reset_column_information
    FakeCdnConfiguration.where(type: 'redhat_cdn').each do |config|
      config.update!(type: 'custom_cdn') unless Katello::Resources::CDN::CdnResource.redhat_cdn?(config.url)
    end
  end
end
