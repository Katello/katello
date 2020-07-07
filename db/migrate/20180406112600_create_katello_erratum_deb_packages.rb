class CreateKatelloErratumDebPackages < ActiveRecord::Migration[4.2]
  def change
    create_table :katello_erratum_deb_packages do |t|
      t.references :erratum
      t.string :name, limit: 255
      t.string :version, limit: 255
      t.string :filename, limit: 255
      t.string :release, limit: 255

      t.timestamps
    end
  end
end
