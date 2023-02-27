class SetNewAcsVerifySslDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:katello_alternate_content_sources, :verify_ssl, nil)
  end
end
