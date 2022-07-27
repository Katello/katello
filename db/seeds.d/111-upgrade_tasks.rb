UpgradeTask.define_tasks(:katello) do
  [
    {:name => 'katello:correct_repositories', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:correct_puppet_environments', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:clean_backend_objects', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:upgrades:3.8:clear_checksum_type'},
    {:name => 'katello:upgrades:3.10:clear_invalid_repo_credentials'},
    {:name => 'katello:upgrades:3.10:update_gpg_key_urls'},
    {:name => 'katello:upgrades:3.11:import_yum_metadata'},
    {:name => 'katello:upgrades:3.11:update_puppet_repos'},
    {:name => 'katello:upgrades:3.11:clear_checksum_type', :task_name => 'katello:upgrades:3.8:clear_checksum_type'},
    {:name => 'katello:upgrades:3.12:remove_pulp2_notifier'},
    {:name => 'katello:upgrades:3.13:republish_deb_metadata'},
    {:name => 'katello:upgrades:3.15:set_sub_facet_dmi_uuid'},
    {:name => 'katello:upgrades:3.15:reindex_rpm_modular'},
    {:name => 'katello:upgrades:3.16:update_applicable_el8_hosts'},
    {:name => 'katello:upgrades:3.18:add_cvv_export_history_metadata'},
    {:name => 'katello:upgrades:3.18:create_missing_module_stream_erratum_packages'}
  ]
end
