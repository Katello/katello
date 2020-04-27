class AddApplicabilityIndicestoKatelloHostAvailableModuleStreams < ActiveRecord::Migration[6.0]
  def up
    add_index :katello_host_available_module_streams,
      [:host_id, :available_module_stream_id, :status],
      :name => 'rpm_and_module_applicability_related_indices'
  end

  def down
    remove_index :katello_host_available_module_streams,
      :name => 'rpm_and_module_applicability_related_indices'
  end
end
