class DeleteErratumInstallBatchSizeSetting < ActiveRecord::Migration[6.0]
  def change
    Setting.where(name: 'erratum_install_batch_size').delete_all
  end
end
