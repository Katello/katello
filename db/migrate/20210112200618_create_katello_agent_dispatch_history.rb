class CreateKatelloAgentDispatchHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :katello_agent_dispatch_histories do |t|
      t.integer :host_id, null: false, foreign_key: true
      t.text :status
      t.datetime :accepted_at
    end
  end
end
