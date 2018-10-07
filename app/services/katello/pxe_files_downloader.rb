module Katello
  class PxeFilesDownloader
    attr_accessor :capsule, :repository

    def initialize(repository, capsule)
      @capsule = capsule
      @repository = repository
    end

    def download_files
      os = Redhat.find_or_create_operating_system(repository)
      medium_provider = Katello::ManagedContentMediumProvider.new(
        OpenStruct.new(
          content_source: capsule,
          kickstart_repository: repository))

      ueber_cert = ::Cert::Certs.ueber_cert(repository.organization)
      cert = OpenSSL::X509::Certificate.new(ueber_cert[:cert])
      key = OpenSSL::PKey::RSA.new(ueber_cert[:key])

      os.boot_file_sources(medium_provider).values.map do |source_pxe_file|
        fetch(source_pxe_file, cert, key)
      end
    end

    private

    def fetch(url, cert, key)
      response = RestClient::Request.execute(:method => :get,
                                  :url => url,
                                  :timeout => SETTINGS[:katello][:rest_client_timeout],
                                  :ssl_client_cert => cert,
                                  :ssl_client_key => key,
                                  :raw_response => true)
      Rails.logger.info("retrieved #{url}")
      response
    rescue StandardError => e
      Rails.logger.warn("Exception -> #{e.inspect} when retrieving #{url}")
    end
  end
end
