module Katello
  module Pulp3
    module ContentViewVersion
      class ImportValidator
        attr_accessor :metadata, :path, :content_view
        def initialize(content_view:, path:, metadata:)
          self.content_view = content_view
          self.path = path
          self.metadata = metadata
        end

        def check!
          unless content_view.default?
            ensure_importing_cvv_does_not_exist!
            ensure_from_cvv_exists!
          end
          ensure_repositories_metadata_are_in_the_library!
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

        def ensure_repositories_metadata_are_in_the_library!
          repos_in_library = Katello::Repository.
                              in_default_view.
                              exportable.
                              joins(:product => :provider, :content_view_version => :content_view).
                              joins(:root).
                              where("#{::Katello::ContentView.table_name}.organization_id" => content_view.organization_id).
                              pluck("#{::Katello::Product.table_name}.name",
                                    "#{::Katello::RootRepository.table_name}.name",
                                    "#{::Katello::Provider.table_name}.provider_type"
                                    )

          # repos_in_library look like [["prod1", "repo1", "Anonymous"], ["prod2", "repo2", "Red Hat"]]
          product_repos_in_library = repos_in_library.map { |product, repo, provider| [product, repo, provider == ::Katello::Provider::REDHAT] }
          product_repos_in_metadata = metadata[:repository_mapping].values.map { |repo| [repo[:product], repo[:repository], repo[:redhat]] }
          # product_repos_in_library & product_repos_in_metadata look like [["prod1", "repo1", false], ["prod2", "repo2", false]]
          product_repos_not_in_library = product_repos_in_metadata - product_repos_in_library
          unless product_repos_not_in_library.blank?
            repos_in_import = generate_product_repo_i18n_string(product_repos_not_in_library)
            fail _("The following repositories provided in the import metadata are either not available in the Library or are of incorrect Respository Type. "\
                    "Please add or enable the repositories before importing\n "\
                    "%{repos}" % { content_view: content_view.name, repos: repos_in_import.join("")}
                  )
          end
        end

        def generate_product_repo_i18n_string(product_repos)
          # product_repos look like [["prod1", "repo1", false], ["prod2", "repo2", false]]
          product_repos.map do |product, repo, redhat|
            repo_type = redhat ? _("Red Hat") : _("Custom")
            _("\n* Product = '%{product}', Repository = '%{repository}', Repository Type = '%{repo_type}'" % { product: product,
                                                                                                               repository: repo,
                                                                                                               repo_type: repo_type})
          end
        end
      end
    end
  end
end
