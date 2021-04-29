module Katello
  module Pulp3
    module ContentViewVersion
      class ImportValidator
        attr_accessor :metadata, :path, :content_view, :smart_proxy

        delegate :organization, :to => :content_view

        def initialize(content_view:, path:, metadata:, smart_proxy:)
          self.content_view = content_view
          self.path = path
          self.metadata = metadata
          self.smart_proxy = smart_proxy
        end

        def check!
          ensure_pulp_importable!
          unless content_view.default?
            ensure_importing_cvv_does_not_exist!
            ensure_from_cvv_exists!
          end
          ensure_manifest_imported!
          ensure_metadata_matches_repos_in_library!
          ensure_redhat_products_metadata_are_in_the_library!
        end

        def ensure_pulp_importable!
          api = ::Katello::Pulp3::Api::Core.new(@smart_proxy).importer_check_api
          response = api.pulp_import_check_post(toc: "#{@path}/#{@metadata[:toc]}")
          unless response.toc.is_valid
            fail response.toc.messages.join("\n")
          end
        end

        def ensure_importing_cvv_does_not_exist!
          major = metadata[:content_view_version][:major]
          minor = metadata[:content_view_version][:minor]

          if ::Katello::ContentViewVersion.where(major: major, minor: minor, content_view: content_view).exists?
            fail _("Content View Version specified in the metadata - '%{name}' already exists. "\
                    "If you wish to replace the existing version, delete %{name} and try again. " % { name: "#{content_view.name} #{major}.#{minor}" })
          end
        end

        def ensure_from_cvv_exists!
          major = metadata[:content_view_version][:major]
          minor = metadata[:content_view_version][:minor]

          if metadata[:from_content_view_version].present?
            from_major = metadata[:from_content_view_version][:major]
            from_minor = metadata[:from_content_view_version][:minor]

            unless ::Katello::ContentViewVersion.where(major: from_major, minor: from_minor, content_view: content_view).exists?
              fail _("Prior Content View Version specified in the metadata - '%{name}' does not exist. "\
                      "Please import the metadata for '%{name}' before importing '%{current}' " % { name: "#{content_view.name} #{from_major}.#{from_minor}",
                                                                                                    current: "#{content_view.name} #{major}.#{minor}"})
            end
          end
        end

        def ensure_manifest_imported!
          rh_repos = ::Katello::Pulp3::ContentViewVersion::Import.metadata_map(metadata, redhat_only: true)
          if rh_repos.any? && !content_view.organization.manifest_imported?
            fail _("No manifest found. Import a manifest with the appropriate subscriptions "\
                   "before importing content.")
          end
        end

        def repos_in_library
          ::Katello::Pulp3::ContentViewVersion::Import.
                              repositories_in_library(content_view.organization)
        end

        def metadata_map
          @metadata_map ||= ::Katello::Pulp3::ContentViewVersion::Import.metadata_map(metadata)
        end

        def ensure_metadata_matches_repos_in_library!
          metadata_map = ::Katello::Pulp3::ContentViewVersion::Import.metadata_map(metadata)
          interested_repos = ::Katello::Pulp3::ContentViewVersion::Import.
                                      intersecting_repos_library_and_metadata(organization: organization,
                                                                              metadata: metadata)
          bad_repos = interested_repos.select do |repo|
            repo_in_metadata = metadata_map[[repo.product.label, repo.label]]
            repo.redhat? != repo_in_metadata[:redhat] ||
              repo.slice(:name, :label, :content_type) != repo_in_metadata.slice(:name, :label, :content_type)
          end

          if bad_repos.any?
            repos_to_report = bad_repos.map { |repo| [repo.product.label, repo.label] }
            fail _("The following repositories provided in the import metadata have an incorrect content type or provider type. "\
                    "Make sure the export and import repositories are of the same type before importing\n "\
                    "%{repos}" % { content_view: content_view.name,
                                   repos: generate_product_repo_i18n_string(repos_to_report).join("")}
                  )
          end
        end

        def ensure_redhat_products_metadata_are_in_the_library!
          products_in_library = ::Katello::Product.in_org(organization).redhat.pluck(:label)

          # Map products to repositories in the metadata
          # {product_label: [repositories with this product]}
          products_in_metadata_map = {}

          metadata[:repositories].values.each do |repo|
            next unless repo[:redhat]
            products_in_metadata_map[repo[:product][:label]] ||= []
            products_in_metadata_map[repo[:product][:label]] << repo
          end

          products_not_in_library = products_in_metadata_map.keys - products_in_library

          unless products_not_in_library.blank?
            # make a list of [product_name, repo_name] pairs to report to the user
            product_repos = []
            products_not_in_library.each do |prod|
              products_in_metadata_map[prod].each do |repo|
                product_name = metadata[:products][prod][:name]
                repo_name = repo[:name]
                product_repos << [product_name, repo_name]
              end
            end

            repos_in_import = generate_product_repo_i18n_string(product_repos)
            fail _("The organization's manifest does not contain the subscriptions required to enable the following repositories.\n "\
                    "%{repos}" % { content_view: content_view.name, repos: repos_in_import.join("")}
                  )
          end
        end

        def generate_product_repo_i18n_string(product_repos)
          # product_repos look like [["prod1", "repo1", false], ["prod2", "repo2", false]]
          product_repos.map do |product, repo|
            _("\n* Product = '%{product}', Repository = '%{repository}'" % { product: product, repository: repo })
          end
        end
      end
    end
  end
end
