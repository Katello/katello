module Katello
  module Util
    class CdnVarSubstitutor
      attr_reader :good_listings
      attr_reader :bad_listings
      # cdn_resource - an object providing access to CDN. It has to
      # provide a get method that takes a path (e.g.
      # /content/rhel/6.2/listing) and returns the body response)
      def initialize(cdn_resource)
        @resource = cdn_resource
      end

      # takes path e.g. "/rhel/server/5/$releasever/$basearch/os"
      # returns PathWithSubstitutions objects
      #
      #  { {"releasever" => "6Server", "basearch" => "i386"} =>  "/rhel/server/5/6Server/i386/os",
      #    {"releasever" => "6Server", "basearch" => "x86_64"} =>  "/rhel/server/5/6Server/x84_64/os"}
      #
      # values are loaded from CDN
      def substitute_vars(path)
        find_substitutions([PathWithSubstitutions.new(path, {})])
      end

      def validate_substitutions(content, substitutions)
        path_with_subs = PathWithSubstitutions.new(content.contentUrl, substitutions)
        real_path = path_with_subs.apply_substitutions
        unused_substitutions = path_with_subs.unused_substitutions
        needed_substitutions = PathWithSubstitutions.new(real_path, {}).substitutions_needed

        if unused_substitutions.any?
          fail Errors::CdnSubstitutionError, _("%{unused_substitutes} cannot be specified for %{content_name}"\
                 " as that information is not substitutable in %{content_url} ") %
              { unaccepted_substitutions: unused_substitutions, content_name: content.name, content_url: content.contentUrl }
        end

        if needed_substitutions.any?
          fail Errors::CdnSubstitutionError, _("Missing arguments %{substitutions} for %{content_url}") %
              { substitutions: needed_substitutions.join(','), content_url: real_path }
        end

        unless any_valid_metadata_file?(real_path)
          @resource.log :error, "No valid metadata files found for #{real_path}"
          fail Errors::CdnSubstitutionError, _("The path %{real_path} does not seem to be a valid repository."\
                 " If you think this is an error, please try refreshing your manifest.") % {real_path: real_path}
        end
      end

      def any_valid_metadata_file?(repo_path)
        ['repodata/repomd.xml', 'PULP_MANIFEST', '.treeinfo', 'treeinfo'].any? { |filename| valid_path?(repo_path, filename) }
      end

      protected

      def find_substitutions(paths_with_substitutions)
        to_resolve = paths_with_substitutions.select { |path| path.substitutable? }
        resolved = paths_with_substitutions - to_resolve

        return resolved if to_resolve.empty?

        futures = to_resolve.map do |path_with_substitution|
          Concurrent.future do
            path_with_substitution.resolve_substitutions(@resource)
          end
        end

        futures.each do |future|
          begin
            resolved << future.value
          rescue StandardError => e
            Rails.logger.error("Error Recieved: #{e.to_s}")
            Rails.logger.error("Error Recieved: #{e.backtrace.join("\n")}")
          end
        end

        find_substitutions(resolved.compact.flatten)
      end

      def valid_path?(path, postfix)
        @resource.get(File.join(path, postfix)).present?
      rescue RestClient::MovedPermanently
        return true
      rescue Errors::NotFound
        return false
      end
    end
  end
end
