class elasticsearch::params {
  # memory setting
  $min_mem = katello_config_value('es_min_mem')
  $max_mem = katello_config_value('es_max_mem')
}
