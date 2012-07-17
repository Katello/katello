class elasticsearch::params {
  # memory setting
  $min_mem = katello_config_value('es_min_mem')
  $max_mem = katello_config_value('es_max_mem')

  # database reinitialization flag
  $reset_data = katello_config_value('reset_data')
}
