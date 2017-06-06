class signo::config {
  file {
    "/etc/signo/sso.yml":
    content => template("signo/etc/signo/sso.yml.erb"),
    owner   => "root",
    group   => "root",
    mode    => "644"
  }
}
