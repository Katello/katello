class AddNvaToKatelloErratumDebPackages < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_erratum_deb_packages, :architecture, :string
    add_column :katello_erratum_deb_packages, :nva, :string
  end
end
