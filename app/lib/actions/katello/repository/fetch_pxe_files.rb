module Actions
  module Katello
    module Repository
      class FetchPxeFiles < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :id, Integer
          param :capsule_id, Integer
        end

        def run
          repository = ::Katello::Repository.find(input[:id])
          if repository.distribution_bootable? &&
             repository.download_policy == ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND

            capsule = if input[:capsule_id].present?
                        SmartProxy.unscoped.find(input[:capsule_id])
                      else
                        SmartProxy.default_capsule!
                      end
            repo_path = repository.full_path(capsule, true).chomp("/")

            os = Redhat.find_or_create_operating_system(repository)

            ueber_cert = ::Cert::Certs.ueber_cert(repository.organization)
            cert = OpenSSL::X509::Certificate.new(ueber_cert[:cert])
            key = OpenSSL::PKey::RSA.new(ueber_cert[:key])

            Redhat::PXEFILES.each_key do |pxe_file|
              fetch("#{repo_path}/#{os.url_for_boot(pxe_file)}", cert, key)
            end
          end
        end

        def fetch(url, cert, key)
          RestClient::Request.execute(:method => :get,
                                      :url => url,
                                      :timeout => SETTINGS[:katello][:rest_client_timeout],
                                      :ssl_client_cert => cert,
                                      :ssl_client_key => key)
          Rails.logger.info("retrieved #{url}")
        rescue StandardError => e
          Rails.logger.warn("Exception -> #{e.inspect} when retrieving #{url}")
        end
      end
    end
  end
end
