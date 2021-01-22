class CreateKatelloAgentDispatchHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :katello_agent_dispatch_histories do |t|
      t.integer :host_id, null: false, foreign_key: true
      t.datetime :accepted_at
      t.string :dynflow_execution_plan_id
      t.integer :dynflow_step_id
      t.text :result
    end
  end
end
