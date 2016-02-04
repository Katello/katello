module Katello
  module Pulp
    class ContentCountsCalculator
      def initialize(repos)
        @repos = repos
      end

      def calculate
        counts = {
          :yum_repositories => 0,
          :packages => 0,
          :package_groups => 0,
          :errata => 0,
          :puppet_repositories => 0,
          :puppet_modules => 0,
          :docker_repositories => 0,
          :docker_images => 0
        }

        @repos.each do |repo|
          case
          when repo_type?(repo, 'rpm')
            counts[:yum_repositories] += 1
            counts[:packages] += get_unit_count(repo, 'rpm')
            counts[:package_groups] += get_unit_count(repo, 'package_group')
            counts[:errata] += get_unit_count(repo, 'erratum')
          when repo_type?(repo, 'docker')
            counts[:docker_repositories] += 1
            counts[:docker_images] += get_unit_count(repo, 'docker_image')
          when repo_type?(repo, 'puppet')
            counts[:puppet_repositories] += 1
            counts[:puppet_modules] += get_unit_count(repo, 'puppet_module')
          end
        end

        counts
      end

      protected

      def repo_type?(repo, repo_type)
        repo['notes'] && (repo['notes']['_repo-type'] == "#{repo_type}-repo")
      end

      def get_unit_count(repo, unit_type)
        if repo['content_unit_counts']
          repo['content_unit_counts'][unit_type] || 0
        else
          0
        end
      end
    end
  end
end
