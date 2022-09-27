module Katello
  module ContentSourceHelper
    def missing_content_source(host)
      <<~CMD
        echo "Host [#{host.name}] doesn't have an assigned content source!"
        exit 1
      CMD
    end

    def prepare_ssl_cert(ca_cert)
      <<~CMD
        # Prepare SSL certificate

        KATELLO_SERVER_CA_CERT=/etc/rhsm/ca/katello-server-ca.pem
        SSL_CA_CERT=$(mktemp)
        cat << EOF > $SSL_CA_CERT
        #{ca_cert}
        EOF

        mkdir -p /etc/rhsm/ca
        cp -f $SSL_CA_CERT $KATELLO_SERVER_CA_CERT
        chmod 644 $KATELLO_SERVER_CA_CERT

      CMD
    end

    def configure_subman(content_source)
      <<~CMD
        # Configure subscription-manager
        RHSM_CFG=/etc/rhsm/rhsm.conf

        test -f $RHSM_CFG.bak || cp $RHSM_CFG $RHSM_CFG.bak

        subscription-manager config \
          --server.hostname="#{content_source.rhsm_url.host}" \
          --server.port="#{content_source.rhsm_url.port}" \
          --server.prefix="#{content_source.rhsm_url.path}" \
          --rhsm.repo_ca_cert="$KATELLO_SERVER_CA_CERT" \
          --rhsm.baseurl="#{content_source.pulp_content_url}"

        subscription-manager facts --update
      CMD
    end

    def reconfigure_yggdrasild(host)
      template = Template.find_by(name: 'remote_execution_pull_setup')
      return '' unless template

      source = Foreman::Renderer.get_source(template: template, host: host)
      scope = Foreman::Renderer.get_scope(source: source, host: host)
      Foreman::Renderer.render(source, scope)
    end
  end
end
