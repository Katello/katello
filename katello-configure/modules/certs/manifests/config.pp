class certs::config {

  $candlepin_cert_name = "candlepin-cert"
  $qpid_cert_name = "qpid-broker"
  $qpid_client_cert_name = "qpid-client"

  $ssl_build_path = '/root/ssl-build'
  $ssl_tool_common = "--set-country '${certs::params::ssl_ca_country}' --set-state '${certs::params::ssl_ca_state}' --set-city '${certs::params::ssl_ca_city}' --set-org-unit '${certs::params::ssl_ca_org_unit}' --set-email '${certs::params::ssl_ca_email}'"

  $katello_pub_cert_name = "KATELLO-TRUSTED-SSL-CERT"
  $katello_private_key_name = "KATELLO-PRIVATE-SSL-KEY"
  $katello_pub_cert = "/usr/share/katello/$katello_pub_cert_name"
  $katello_private_key = "${ssl_build_path}/$katello_private_key_name"
  $katello_www_pub_dir = "/var/www/html/pub"

  $candlepin_pub_cert_name = "$candlepin_cert_name.crt"
  $candlepin_private_key_name = "$candlepin_cert_name.key"
  $candlepin_pub_cert = "/usr/share/katello/$candlepin_pub_cert_name"
  $candlepin_private_key = "${ssl_build_path}/$candlepin_private_key_name"

  exec { "generate-ssl-ca-password":
    command => "openssl rand -base64 24 > ${certs::params::ssl_ca_password_file}",
    path => "/usr/bin",
    creates => "${certs::params::ssl_ca_password_file}"
  }

  exec { "generate-candlepin-ca-password":
    command => "openssl rand -base64 24 > ${certs::params::candlepin_ca_password_file}",
    path => "/usr/bin",
    creates => "${certs::params::candlepin_ca_password_file}"
  }

  file { "${certs::params::ssl_ca_password_file}":
    owner => "root",
    group => "root",
    mode => 600,
    require => Exec["generate-ssl-ca-password"]
  }

  file { "${certs::params::candlepin_ca_password_file}":
    owner => "root",
    group => "root",
    mode => 600,
    require => Exec["generate-candlepin-ca-password"]
  }
  
  file { "${katello_www_pub_dir}":
    ensure => "directory",
    owner  => "apache",
    group  => "apache",
    mode   => 755,
  }

  file { $certs::params::katello_pki_dir:
    owner => "root",
    group => "katello",
    mode => 750,
    ensure => "directory"
  }

  exec { "generate-ssl-keystore":
    command   => "openssl pkcs12 -export -in /etc/candlepin/certs/candlepin-ca.crt -inkey /etc/candlepin/certs/candlepin-ca.key -out ${certs::params::katello_keystore} -name tomcat -CAfile ${candlepin_pub_cert} -caname root -password \"file:${certs::params::keystore_password_file}\" 2>>${katello::params::configure_log_base}/certificates.log",
    path      => "/usr/bin",
    creates   => $certs::params::katello_keystore,
    notify    => Service["tomcat6"],
    require   => [File[$certs::params::katello_pki_dir], Exec["deploy-candlepin-certificate-to-cp"], File["${katello::params::configure_log_base}"]]
  }

  file { $certs::params::katello_keystore:
    owner => "root",
    group => "katello",
    mode => 640,
    require => [Exec["generate-ssl-keystore"]]
  }

  file { "/usr/share/tomcat6/conf/keystore":
    ensure => link,
    target => $certs::params::katello_keystore,
    require => File[$certs::params::katello_keystore],
    before  => Service["tomcat6"],
  }

  $candlepin_key_pair_name = "katello-${candlepin_cert_name}-key-pair"

  file { "${ssl_build_path}":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 700
  }

  file { "${ssl_build_path}/rhsm-katello-reconfigure":
    content => template("certs/rhsm-katello-reconfigure.erb"),
    owner => "root",
    group => "root",
    mode => 700,
    require => File["${ssl_build_path}"]
  }

  exec { "generate-candlepin-certificate":
    cwd => '/root',
    command => "katello-ssl-tool --gen-ca -p \"$(cat ${certs::params::candlepin_ca_password_file})\" --set-country '${certs::params::ssl_ca_country}' --set-state '${certs::params::ssl_ca_state}' --set-city '${certs::params::ssl_ca_city}' --set-org '${certs::params::ssl_ca_org}' --set-org-unit '${certs::params::ssl_ca_org_unit}' --set-common-name `hostname` --set-email '' --ca-key '${candlepin_cert_name}.key' --ca-cert '${candlepin_cert_name}.crt' --ca-cert-rpm  '${candlepin_key_pair_name}' 2>>${katello::params::configure_log_base}/certificates.log",
    path => "/usr/bin:/bin",
    creates => "${ssl_build_path}/$candlepin_cert_name.crt",
    require => [File["${certs::params::candlepin_ca_password_file}"], File["${katello::params::configure_log_base}"]],
    notify => Exec["generate-candlepin-consumer-certificate"] # regenerate consumer RPM as well
  }

  $candlepin_consumer_name = "${candlepin_cert_name}-consumer-${fqdn}"
  $candlepin_consumer_summary = "Subscription-manager consumer certificate for Katello instance ${fqdn}"
  $candlepin_consumer_description = "Consumer certificate and post installation script that configures rhsm."

  exec { "generate-candlepin-consumer-certificate":
    cwd       => "${katello_www_pub_dir}",
    command   => "gen-rpm.sh --name '${candlepin_consumer_name}' --version 1.0 --release 1 --packager None --vendor None --group 'Applications/System' --summary '${candlepin_consumer_summary}' --description '${candlepin_consumer_description}' --requires subscription-manager --post ${ssl_build_path}/rhsm-katello-reconfigure /etc/rhsm/ca/candlepin-local.pem:644=${ssl_build_path}/$candlepin_cert_name.crt 2>>${katello::params::configure_log_base}/certificates.log && /sbin/restorecon ./*rpm",
    path      => "/usr/share/katello/certs:/usr/bin:/bin",
    creates   => "${katello_www_pub_dir}/${candlepin_consumer_name}-1.0-1.noarch.rpm",
    require   => [Exec["generate-candlepin-certificate"], File["${ssl_build_path}/rhsm-katello-reconfigure"], File["${katello::params::configure_log_base}"]]
  }

  exec { "create-candlepin-consumer-certificate-link":
    cwd     => "${katello_www_pub_dir}",
    command => "ln -sf ${candlepin_consumer_name}-1.0-1.noarch.rpm ${candlepin_cert_name}-consumer-latest.noarch.rpm",
    path    => "/usr/bin:/bin",
    creates => "${katello_www_pub_dir}/${candlepin_cert_name}-consumer-latest.noarch.rpm",
    require => Exec["generate-candlepin-certificate"]
  }

  exec { "deploy-candlepin-certificate":
    command => "rpm -qp /root/ssl-build/$(grep $candlepin_cert_name.*noarch.rpm /root/ssl-build/latest.txt) | xargs rpm -q; if [ $? -ne 0 ]; then rpm -Uvh --force /root/ssl-build/$(grep noarch.rpm /root/ssl-build/latest.txt); fi",
    path => "/bin:/usr/bin",
    creates => "$candlepin_pub_cert",
    require => Exec["create-candlepin-consumer-certificate-link"],
    before => Class["apache2::service"]
  }

  exec { "deploy-candlepin-certificate-to-cp":
    command => "openssl x509 -in $candlepin_pub_cert -out /etc/candlepin/certs/candlepin-ca.crt; openssl rsa -in $candlepin_private_key -out /etc/candlepin/certs/candlepin-ca.key -passin 'file:/etc/katello/candlepin_ca_password-file' 2>>${katello::params::configure_log_base}/certificates.log",
    path => "/bin:/usr/bin",
    creates => ["/etc/candlepin/certs/candlepin-ca.crt", "/etc/candlepin/certs/candlepin-ca.key"],
    require => [Exec["deploy-candlepin-certificate"], File["${katello::params::configure_log_base}"]],
    before => Class["apache2::service"]
  }

  file { ["$certs::params::candlepin_certs_dir/candlepin-ca.key"]:
    owner => "root",
    group => "katello",
    mode => 640,
    require => Exec["deploy-candlepin-certificate-to-cp"],
    before => Class["candlepin::service"]
  }


  file { ["$certs::params::candlepin_certs_dir/candlepin-ca.crt"]:
    owner => "root",
    group => "katello",
    mode => 644,
    require => Exec["deploy-candlepin-certificate-to-cp"],
    before => Class["candlepin::service"]
  }


  require "katello::params"

  if ($katello::params::deployment != 'headpin') {
      $qpid_package = "katello-${qpid_cert_name}-key-pair"

      exec { "generate-ssl-qpid-broker-certificate":
        cwd => '/root',
        command => "katello-ssl-tool --gen-server -p \"$(cat ${certs::params::candlepin_ca_password_file})\" --ca-cert '${candlepin_pub_cert}' --ca-key '${candlepin_private_key}' $ssl_tool_common --cert-expiration '${certs::params::ssl_cert_expiration}' --set-org 'pulp' --server-cert '${qpid_cert_name}.crt' --server-cert-req '${qpid_cert_name}.req' --set-email '' --server-key '${qpid_cert_name}.key' --server-tar 'katello-${qpid_cert_name}-key-pair' --server-rpm 'katello-${qpid_cert_name}-key-pair' 2>>${katello::params::configure_log_base}/certificates.log",
        path => "/usr/bin:/bin",
        creates => "${ssl_build_path}/$fqdn/$qpid_cert_name.crt",
        require => [File["${certs::params::candlepin_ca_password_file}"], Exec["deploy-candlepin-certificate"], File["${katello::params::configure_log_base}"]]
      }

      exec { "deploy-ssl-qpid-broker-certificate":
        command => "rpm -qp /root/ssl-build/$fqdn/$(grep noarch.rpm /root/ssl-build/$fqdn/latest.txt) | xargs rpm -q; if [ $? -ne 0 ]; then rpm -Uvh --force /root/ssl-build/$fqdn/$(grep $qpid_cert_name.*noarch.rpm /root/ssl-build/$fqdn/latest.txt); fi",
        path => "/bin:/usr/bin",
        creates => "/etc/pki/tls/certs/$qpid_cert_name.crt",
        require => Exec["generate-ssl-qpid-broker-certificate"],
      }

      $nss_db_dir = "$certs::params::katello_pki_dir/nssdb/"

      exec { "generate-nss-password":
        command => "openssl rand -base64 24 > ${certs::params::nss_db_password_file}",
        path => "/usr/bin",
        creates => "${certs::params::nss_db_password_file}"
      }

      file { "${certs::params::nss_db_password_file}":
        owner => "root",
        group => "katello",
        mode => 640,
        require => Exec["generate-nss-password"]
      }

      exec { "generate-pk12-password":
        command => "openssl rand -base64 24 > ${certs::params::ssl_pk12_password_file}",
        path => "/usr/bin",
        creates => "${certs::params::ssl_pk12_password_file}"
      }

      file { "${certs::params::ssl_pk12_password_file}":
        owner => "root",
        group => "root",
        mode => 600,
        require => Exec["generate-pk12-password"]
      }

      file { $nss_db_dir:
        owner => "root",
        group => "katello",
        mode => 744,
        ensure => "directory"
      }

      file { ["$nss_db_dir/cert8.db", "$nss_db_dir/key3.db", "$nss_db_dir/secmod.db"]:
        owner => "root",
        group => "katello",
        mode => 640,
        require => Exec["create-nss-db"],
        before => Class["qpid::service"]
      }

      exec { "create-nss-db":
        command => "certutil -N -d '${nss_db_dir}' -f '${certs::params::nss_db_password_file}' 2>>${katello::params::configure_log_base}/certificates.log",
        path    => "/usr/bin",
        require => [
          File["${certs::params::nss_db_password_file}"],
          File[$nss_db_dir],
          Exec["deploy-ssl-qpid-broker-certificate"],
          File["${katello::params::configure_log_base}"]
          ],
        before  => Class["qpid::service"],
        creates => ["$nss_db_dir/cert8.db", "$nss_db_dir/key3.db", "$nss_db_dir/secmod.db"],
        notify => [
          Exec["add-candlepin-cert-to-nss-db"],
          Exec["add-broker-cert-to-nss-db"],
          Exec["generate-pfx-for-nss-db"],
          Exec["add-private-key-to-nss-db"],
          Service["qpidd"],
        ];
      }

      exec { "add-candlepin-cert-to-nss-db":
        command => "certutil -A -d '${nss_db_dir}' -n 'ca' -t 'TCu,Cu,Tuw' -a -i '${candlepin_pub_cert}' 2>>${katello::params::configure_log_base}/certificates.log",
        path    => "/usr/bin",
        require => [Exec["create-nss-db"], Exec["deploy-candlepin-certificate-to-cp"], File["${katello::params::configure_log_base}"]],
        before => Class["qpid::service"],
        refreshonly => true,
      }

      exec { "add-broker-cert-to-nss-db":
        command => "certutil -A -d '${nss_db_dir}' -n 'broker' -t ',,' -a -i '${ssl_build_path}/$fqdn/$qpid_cert_name.crt' 2>>${katello::params::configure_log_base}/certificates.log",
        path    => "/usr/bin",
        require => [Exec["create-nss-db"], Exec["deploy-candlepin-certificate-to-cp"], File["${katello::params::configure_log_base}"]],
        before => Class["qpid::service"],
        refreshonly => true,
      }

      exec { "generate-pfx-for-nss-db":
        command => "openssl pkcs12 -in ${ssl_build_path}/$fqdn/$qpid_cert_name.crt -inkey ${ssl_build_path}/$fqdn/$qpid_cert_name.key -export -out '${ssl_build_path}/$fqdn/$qpid_cert_name.pfx' -password 'file:${certs::params::ssl_pk12_password_file}' 2>>${katello::params::configure_log_base}/certificates.log",
        path    => "/usr/bin",
        require => [Exec["create-nss-db"], File["${certs::params::ssl_pk12_password_file}"], File["${katello::params::configure_log_base}"]],
        before => Class["qpid::service"],
        refreshonly => true,
      }

      exec { "add-private-key-to-nss-db":
        command => "pk12util -i '${ssl_build_path}/$fqdn/$qpid_cert_name.pfx' -d '${nss_db_dir}' -w '${certs::params::ssl_pk12_password_file}' -k '${certs::params::nss_db_password_file}' 2>>${katello::params::configure_log_base}/certificates.log",
        path    => "/usr/bin",
        require => [Exec["add-broker-cert-to-nss-db"], Exec["generate-pfx-for-nss-db"], File["${katello::params::configure_log_base}"]],
        before => Class["qpid::service"],
        refreshonly => true,
      }

      # qpid client certificates
      exec { "generate-ssl-qpid-client-certificate":
        cwd => '/root',
        command => "katello-ssl-tool --gen-server -p \"$(cat ${certs::params::candlepin_ca_password_file})\" --ca-cert '${candlepin_pub_cert}' --ca-key '${candlepin_private_key}' $ssl_tool_common --cert-expiration '${certs::params::ssl_cert_expiration}' --set-org 'pulp' --server-cert '${qpid_client_cert_name}.crt' --server-cert-req '${qpid_client_cert_name}.req' --set-email '' --server-key '${qpid_client_cert_name}.key' --server-tar 'katello-${qpid_client_cert_name}-key-pair' --server-rpm 'katello-${qpid_client_cert_name}-key-pair' 2>>${katello::params::configure_log_base}/certificates.log",
        path => "/usr/bin:/bin",
        creates => "${ssl_build_path}/$fqdn/$qpid_client_cert_name.crt",
        require => [Exec["deploy-candlepin-certificate"], File["${katello::params::configure_log_base}"], Exec["deploy-ssl-qpid-broker-certificate"]]
      }

      exec { "deploy-ssl-qpid-client-certificate":
        command => "rpm -qp ${ssl_build_path}/$fqdn/$(grep noarch.rpm ${ssl_build_path}/$fqdn/latest.txt) | xargs rpm -q; if [ $? -ne 0 ]; then rpm -Uvh --force ${ssl_build_path}/$fqdn/$(grep $qpid_client_cert_name.*noarch.rpm ${ssl_build_path}/$fqdn/latest.txt); fi",
        path => "/bin:/usr/bin",
        creates => "/etc/pki/tls/certs/$qpid_client_cert_name.crt",
        require => Exec["generate-ssl-qpid-client-certificate"],
        before => Class["pulp::service"]
      }

      # prepare certificate for pulp server
      exec { "strip-qpid-client-certificate":
        command => "cp ${ssl_build_path}/$fqdn/qpid-client.key /etc/pki/pulp/qpid_client_striped.crt; openssl x509 -in ${ssl_build_path}/$fqdn/qpid-client.crt >> /etc/pki/pulp/qpid_client_striped.crt 2>>${katello::params::configure_log_base}/certificates.log",
        path => "/bin:/usr/bin",
        creates => "/etc/pki/pulp/qpid_client_striped.crt",
        require => [Exec["deploy-ssl-qpid-client-certificate"], File["${katello::params::configure_log_base}"]],
        notify  => Exec["reload-apache2"],
        before => Class["pulp::service"]
      }

      file { "/etc/pki/pulp/qpid_client_striped.crt":
        owner => "apache",
        group => "apache",
        mode => 640,
        require => Exec["strip-qpid-client-certificate"]
      }
    }
}
