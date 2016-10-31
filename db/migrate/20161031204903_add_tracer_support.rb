class AddTracerSupport < ActiveRecord::Migration
  def change
    create_table :katello_host_tracers do |t|
      t.references 'host', :null => false, :index => true
      t.string 'application', :null => false
      t.string 'helper'
      t.string 'app_type', :null => false
    end

    add_foreign_key "katello_host_tracers", "hosts",
                    :name => "katello_host_trace_host_id", :column => "host_id"
  end
end
