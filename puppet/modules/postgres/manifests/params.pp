class postgres::params {
  $user     = "postgres"
  $group    = "postgres"
  $uid      = "26"
  $gid      = "26"
  $home     = "/var/lib/pgsql"

  $password_file = katello_config_value('psql_password_file')
}
