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
        path_with_subs = PathWithSubstitutions.new(content.content_url, substitutions)
        real_path = path_with_subs.apply_substitutions
        unused_substitutions = path_with_subs.unused_substitutions
        needed_substitutions = PathWithSubstitutions.new(real_path, {}).substitutions_needed

        if unused_substitutions.any?
          fail Errors::CdnSubstitutionError, _("%{unused_substitutions} cannot be specified for %{content_name}"\
            " as that information is not substitutable in %{content_url} ") %
            { unused_substitutions: unused_substitutions.join(','),
              content_name: content.name,
              content_url: content.content_url }
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
        ['repodata/repomd.xml', 'PULP_MANIFEST', '.treeinfo', 'treeinfo'].any? { |filename| @resource.valid_path?(repo_path, filename) }
      end

      protected

      def find_substitutions(paths_with_substitutions)
        to_resolve = paths_with_substitutions.select { |path| path.substitutable? }
        resolved = paths_with_substitutions - to_resolve

        return resolved if to_resolve.empty?

        to_resolve.in_groups_of(8, false) do |group|
          futures = group.map do |path_with_substitution|
            Concurrent::Promises.future do
              resolve_path(path_with_substitution)
            end
          end

          futures.each do |future|
            resolved << future.value
            Rails.logger.error("Failed at scanning for repository: #{future.reason}") if future.rejected?
          end
        end

        find_substitutions(resolved.compact.flatten)
      end

      def resolve_path(path_with_substitutions)
        if @resource.respond_to?(:fetch_paths)
          @resource.fetch_paths(path_with_substitutions.path).compact.map do |element|
            PathWithSubstitutions.new(element[:path], element[:substitutions])
          end
        elsif @resource.respond_to?(:fetch_substitutions)
          @resource.fetch_substitutions(path_with_substitutions.base_path).compact.map do |value|
            path_with_substitutions.resolve_token(value)
          end
        else
          fail _("Unsupported CDN resource")
        end
      end
    end
  end
end
