module Katello
  module Pulp3
    module ContentViewVersion
      class ImportValidator
        BASEDIR = '/var/lib/pulp'.freeze
        attr_accessor :metadata, :path, :content_view
        def initialize(content_view:, path:, metadata:)
          self.content_view = content_view
          self.path = path
          self.metadata = metadata
        end

        def check!
          check_permissions!
          ensure_importing_cvv_does_not_exist!
          ensure_from_cvv_exists!
          ensure_repositories_metadata_and_content_view_match!
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

        def ensure_repositories_metadata_and_content_view_match!
          product_repos_in_content_view = content_view.repositories.yum_type.map { |repo| [repo.product.name, repo.name, repo.redhat?] }
          product_repos_in_metadata = metadata[:repository_mapping].values.map { |repo| [repo[:product], repo[:repository], repo[:redhat]] }

          product_repos_in_content_view.sort!
          product_repos_in_metadata.sort!
          # product_repos_in_content_view & product_repos_in_metadata look like [["prod1", "repo1", false], ["prod2", "repo2", false]]

          if product_repos_in_content_view != product_repos_in_metadata
            repos_in_content_view = generate_product_repo_i18n_string(product_repos_in_content_view)
            repos_in_import = generate_product_repo_i18n_string(product_repos_in_metadata)

            fail _("Repositories in the importing content view do not match the repositories provided in the import metadata.\n "\
                    "Repositories in Content View '%{content_view}': %{repos_in_content_view}\n "\
                    "Repositories in the Import Metadata: %{repos_in_import}" % { content_view: content_view.name,
                                                                                  repos_in_content_view: repos_in_content_view.join(""),
                                                                                  repos_in_import: repos_in_import.join("")}
                  )
          end
        end

        def check_permissions!
          fail _("Invalid path specified.") if path.blank? || !File.directory?(path)
          fail _("The import path must be in a subdirectory under '%s'." % BASEDIR) unless path.starts_with?(BASEDIR)
          fail _("Pulp user or group unable to read content in '%s'." % path) unless pulp_user_accessible?(path)

          Dir.glob("#{path}/*").each do |file|
            fail _("Pulp user or group unable to read '%s'." % file) unless pulp_user_accessible?(file)
          end
          toc_path = "#{path}/#{metadata[:toc]}"
          fail _("The TOC file specified in the metadata does not exist. %s " % toc_path) unless File.exist?(toc_path)
        end

        def pulp_user_accessible?(path)
          pulp_info = fetch_pulp_user_info
          return false if pulp_info.blank?

          stat = File.stat(path)
          stat.gid.to_s == pulp_info.gid ||
            stat.uid.to_s == pulp_info.uid ||
            stat.mode.to_s(8)[-1].to_i >= 4
        end

        def fetch_pulp_user_info
          pulp_user = nil
          Etc.passwd { |u| pulp_user = u if u.name == 'pulp' }
          pulp_user
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
