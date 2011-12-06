class certs::config {

  $https_cert_name = "httpd-ssl"
  $qpid_cert_name = "qpid-broker"

  if ($certs::params::skip_ssl_ca_generation == "true") {

      exec { "generate-ssl-server-certificate-key":
        command => "rhn-ssl-tool --gen-server --key-only --server-key '${https_cert_name}.key'",
        path => "/usr/bin:/bin",
        creates => "/root/ssl-build/$fqdn/$https_cert_name.key",
      }

      exec { "generate-ssl-server-certificate-request":
        command => "rhn-ssl-tool --gen-server --cert-req-only --set-country '${certs::params::ssl_ca_country}' --set-state '${certs::params::ssl_ca_state}' --set-city '${certs::params::ssl_ca_city}' --set-org '${certs::params::ssl_ca_org}' --set-org-unit '${certs::params::ssl_ca_org_unit}' --set-email '${certs::params::ssl_ca_email}' --cert-expiration '${certs::params::ssl_cert_expiration}' --server-cert-req='${https_cert_name}.req' --server-key='${https_cert_name}.key'",
        path => "/usr/bin:/bin",
        creates => "/root/ssl-build/$fqdn/$https_cert_name.csr",
        require => Exec["generate-ssl-server-certificate-key"]
      }

      exec { "generate-ssl-qpid-broker-certificate-key":
        command => "rhn-ssl-tool --gen-server --key-only --server-key '${qpid_cert_name}.key'",
        path => "/usr/bin:/bin",
        creates => "/root/ssl-build/$fqdn/$qpid_cert_name.key",
      }

      exec { "generate-ssl-qpid-broker-certificate-request":
        command => "rhn-ssl-tool --gen-server --cert-req-only --set-country '${certs::params::ssl_ca_country}' --set-state '${certs::params::ssl_ca_state}' --set-city '${certs::params::ssl_ca_city}' --set-org 'pulp' --set-org-unit '${certs::params::ssl_ca_org_unit}' --set-email '${certs::params::ssl_ca_email}' --cert-expiration '${certs::params::ssl_cert_expiration}' --server-cert-req='${qpid_cert_name}.req' --server-key='${qpid_cert_name}.key'",
        path => "/usr/bin:/bin",
        creates => "/root/ssl-build/$fqdn/$qpid_cert_name.csr",
        require => Exec["generate-ssl-qpid-broker-certificate-key"]
      }

  } else {

      $katello_pub_cert_name = "KATELLO-TRUSTED-SSL-CERT"
      $katello_private_key_name = "KATELLO-PRIVATE-SSL-KEY"
      $katello_pub_cert = "/usr/share/katello/$katello_pub_cert_name"
      $katello_private_key = "/root/ssl-build/$katello_private_key_name"

      exec { "generate-ssl-ca-password":
        command => "openssl rand -base64 24 > ${certs::params::ssl_ca_password_file}",
        path => "/usr/bin",
        creates => "${certs::params::ssl_ca_password_file}"
      }

      file { "${certs::params::ssl_ca_password_file}":
        owner => "root",
        group => "root",
        mode => 600,
        require => Exec["generate-ssl-ca-password"]
      }

      exec { "generate-ssl-ca-certificate":
        command => "rhn-ssl-tool --gen-ca -p \"$(cat ${certs::params::ssl_ca_password_file})\" --set-country '${certs::params::ssl_ca_country}' --set-state '${certs::params::ssl_ca_state}' --set-city '${certs::params::ssl_ca_city}' --set-org '${certs::params::ssl_ca_org}' --set-org-unit '${certs::params::ssl_ca_org_unit}' --set-common-name '${certs::params::ssl_ca_cn}' --set-email '${certs::params::ssl_ca_email}' --ca-key '${katello_private_key_name}' --ca-cert '${katello_pub_cert_name}' --ca-cert-rpm katello-trusted-ssl-cert",
        path => "/usr/bin:/bin",
        creates => "$katello_private_key",
        require => File["${certs::params::ssl_ca_password_file}"]
      }

      exec { "deploy-ssl-ca-certificate":
        command => "rpm -qp ssl-build/$(grep noarch.rpm ssl-build/latest.txt) | xargs rpm -q; if [ $? -ne 0 ]; then rpm -Uvh ssl-build/$(grep noarch.rpm ssl-build/latest.txt); fi",
        path => "/bin:/usr/bin",
        #creates => $$katello_pub_cert,
        require => Exec["generate-ssl-ca-certificate"]
      }

      file { "/var/www/html/pub/${katello_pub_cert_name}":
        source => $katello_pub_cert,
        require => Exec["deploy-ssl-ca-certificate"]
      }

      $katello_pki_dir = "/etc/pki/katello"
      $katello_keystore = "$katello_pki_dir/keystore"

      exec { "generate-keystore-password":
        command => "openssl rand -base64 24 > ${certs::params::keystore_password_file}",
        path => "/usr/bin",
        creates => "${certs::params::keystore_password_file}",
        require => Exec["deploy-ssl-ca-certificate"]
      }

      file { "${certs::params::keystore_password_file}":
        owner => "root",
        group => "tomcat",
        mode => 640,
        require => Exec["generate-keystore-password"]
      }

      file { $katello_pki_dir:
        owner => "root",
        group => "tomcat",
        mode => 750,
        ensure => "directory"
      }

      exec { "generate-ssl-keystore":
        command => "openssl pkcs12 -export -in ${katello_pub_cert} -inkey ${katello_private_key} -out ${katello_keystore} -name tomcat -CAfile ${katello_pub_cert} -caname root -chain -passin \"file:${certs::params::ssl_ca_password_file}\" -password \"file:${certs::params::keystore_password_file}\"",
        path => "/usr/bin",
        creates => $katello_keystore,
        require => [Exec["generate-keystore-password"], File[$katello_pki_dir]]
      }

      file { $katello_keystore:
        owner => "root",
        group => "tomcat",
        mode => 640,
        require => Exec["generate-keystore-password"]
      }

#     file { "/usr/share/tomcat6/conf/keystore":
#       ensure => link,
#       target => $katello_keystore,
#       require => File[$katello_keystore]
#     }

      $https_package = "katello-${https_cert_name}-key-pair"

      exec { "generate-ssl-server-certificate":
        command => "rhn-ssl-tool --gen-server -p \"$(cat ${certs::params::ssl_ca_password_file})\"  --ca-cert '${katello_pub_cert}' --ca-key '${katello_private_key}' --set-country '${certs::params::ssl_ca_country}' --set-state '${certs::params::ssl_ca_state}' --set-city '${certs::params::ssl_ca_city}' --set-org '${certs::params::ssl_ca_org}' --set-org-unit '${certs::params::ssl_ca_org_unit}' --set-email '${certs::params::ssl_ca_email}' --cert-expiration '${certs::params::ssl_cert_expiration}' --server-cert '${https_cert_name}.crt' --server-cert-req '${https_cert_name}.req' --server-key '${https_cert_name}.key' --server-tar '${https_package}' --server-rpm '${https_package}'",
        path => "/usr/bin:/bin",
        creates => "/root/ssl-build/$fqdn/$https_cert_name.crt",
        require => Exec["generate-ssl-ca-certificate"]
      }

      exec { "deploy-ssl-server-certificate":
        command => "rpm -qp ssl-build/$fqdn/$(grep $https_cert_name.*noarch.rpm ssl-build/$fqdn/latest.txt) | xargs rpm -q; if [ $? -ne 0 ]; then rpm -Uvh ssl-build/$fqdn/$(grep noarch.rpm ssl-build/$fqdn/latest.txt); fi",
        path => "/bin:/usr/bin",
        creates => "/etc/pki/tls/certs/$https_cert_name.crt",
        require => Exec["generate-ssl-server-certificate"],
        before => [Exec["generate-ssl-qpid-broker-certificate"], Class["apache2::service"]]
      }

      $qpid_package = "katello-${qpid_cert_name}-key-pair"

      exec { "generate-ssl-qpid-broker-certificate":
        command => "rhn-ssl-tool --gen-server -p \"$(cat ${certs::params::ssl_ca_password_file})\" --ca-cert '${katello_pub_cert}' --ca-key '${katello_private_key}' --set-country '${certs::params::ssl_ca_country}' --set-state '${certs::params::ssl_ca_state}' --set-city '${certs::params::ssl_ca_city}' --set-org 'pulp' --set-org-unit '${certs::params::ssl_ca_org_unit}' --set-email '${certs::params::ssl_ca_email}' --cert-expiration '${certs::params::ssl_cert_expiration}' --server-cert '${qpid_cert_name}.crt' --server-cert-req '${qpid_cert_name}.req' --server-key '${qpid_cert_name}.key' --server-tar 'katello-${qpid_cert_name}-key-pair' --server-rpm 'katello-${qpid_cert_name}-key-pair'",
        path => "/usr/bin:/bin",
        creates => "/root/ssl-build/$fqdn/$qpid_cert_name.crt",
        require => [Exec["generate-ssl-ca-certificate"], Exec["deploy-ssl-server-certificate"]]
      }

      exec { "deploy-ssl-qpid-broker-certificate":
        command => "rpm -qp ssl-build/$fqdn/$(grep noarch.rpm ssl-build/$fqdn/latest.txt) | xargs rpm -q; if [ $? -ne 0 ]; then rpm -Uvh ssl-build/$fqdn/$(grep $qpid_cert_name.*noarch.rpm ssl-build/$fqdn/latest.txt); fi",
        path => "/bin:/usr/bin",
        creates => "/etc/pki/tls/certs/$qpid_cert_name.crt",
        require => Exec["generate-ssl-qpid-broker-certificate"],
      }

      $nss_db_dir = "$katello_pki_dir/nssdb/"

      exec { "generate-nss-password":
        command => "openssl rand -base64 24 > ${certs::params::nss_db_password_file}",
        path => "/usr/bin",
        creates => "${certs::params::nss_db_password_file}"
      }

      file { "${certs::params::nss_db_password_file}":
        owner => "root",
        group => "root",
        mode => 600,
        require => Exec["generate-nss-password"]
      }

      file { $nss_db_dir:
        owner => "root",
        group => "root",
        mode => 744,
        ensure => "directory"
      }

      exec { "create-nss-db":
        command => "certutil -N -d '${nss_db_dir}' -f '${certs::params::nss_db_password_file}'; certutil -A -d '${nss_db_dir}' -n 'ca' -t 'TCu,Cu,Tuw' -a -i '${katello_pub_cert}'; certutil -A -d '${nss_db_dir}' -n 'broker' -t ',,' -a -i '/etc/pki/tls/certs/$qpid_cert_name.crt'; certutil -A -d '${nss_db_dir}' -n 'tomcat' -t ',,' -a -i '/etc/pki/tls/certs/$https_cert_name.crt'",
        path => "/usr/bin",
        require => [Exec["deploy-ssl-qpid-broker-certificate"], Exec["deploy-ssl-server-certificate"], File["${certs::params::nss_db_password_file}"], File[$nss_db_dir]]
      }
  }
}
