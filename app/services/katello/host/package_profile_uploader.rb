module Katello
  module Host
    class PackageProfileUploader
      def initialize(profile_string:, host: nil)
        @profile_string = profile_string
        @host = host
      end

      def upload
        profile = JSON.parse(@profile_string)
        #free the huge string from the memory
        @profile_string = 'TRIMMED'.freeze
        import_package_profile(profile)
      end

      def import_package_profile(profile)
        self.class.import_package_profile_for_host(@host&.id, profile)
      end

      def trigger_applicability_generation
        ::Katello::Host::ContentFacet.trigger_applicability_generation(@host&.id)
      end

      def self.import_package_profile_for_host(host_id, profile)
        host = ::Host.find_by(:id => host_id)
        if host.nil?
          Rails.logger.warn("Host with ID %s not found; continuing" % host_id)
        elsif host.content_facet.nil? || host.content_facet.uuid.nil?
          Rails.logger.warn("Host with ID %s has no content facet; continuing" % host_id)
        else
          begin
            simple_packages = profile.map { |item| ::Katello::SimplePackage.new(item) }
            host.import_package_profile(simple_packages)
          rescue ActiveRecord::InvalidForeignKey # this happens if the host gets deleted in between the "find_by" and "import_package_profile"
            Rails.logger.warn("Host installed package list with ID %s was not able to be written to the DB (host likely is deleted); continuing" % host_id)
          end
        end
      end
    end # of class
  end
end
