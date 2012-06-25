class postgres::params {
  $user     = "postgres"
  $group    = "postgres"
  $uid      = "26"
  $gid      = "26"
  $home     = "/var/lib/pgsql"
  # TODO password is hardcoded
  $password = ""
}
