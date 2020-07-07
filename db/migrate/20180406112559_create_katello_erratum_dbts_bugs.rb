class CreateKatelloErratumDbtsBugs < ActiveRecord::Migration[4.2]
  def change
    create_table :katello_erratum_dbts_bugs do |t|
      t.references :erratum
      t.string :bug_id, limit: 255

      t.timestamps
    end
  end
end
