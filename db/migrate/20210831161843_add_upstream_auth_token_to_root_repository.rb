class AddUpstreamAuthTokenToRootRepository < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_root_repositories, :upstream_authentication_token, :string, limit: 1024
  end
end
