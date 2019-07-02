module Katello
  module Concerns
    module HttpProxyExtensions
      extend ActiveSupport::Concern

      included do
        has_many :root_repositories, :class_name => "::Katello::RootRepository", :foreign_key => :http_proxy_id,
          :inverse_of => :http_proxy, :dependent => :nullify
        after_update :update_default_proxy_setting
        after_commit :update_repository_proxy_details

        def self.default_global_content_proxy
          if Setting[:content_default_http_proxy]
            HttpProxy.unscoped.find_by(name: Setting[:content_default_http_proxy])
          end
        end
      end

      def update_default_proxy_setting
        changes = self.previous_changes
        if changes.key?(:name)
          previous_name = changes[:name].first
          setting = Setting.find_by(name: 'content_default_http_proxy')

          if setting && setting.value == previous_name && !previous_name.blank?
            setting.update_attribute(:value, self.name)
          end
        end
      end

      def update_repository_proxy_details
        changes = self.previous_changes
        if changes.key?(:url) || changes.key?(:username) || changes.key?(:password)

          root_repos = RootRepository.with_selected_proxy(id)

          if self == HttpProxy.default_global_content_proxy
            root_repos += RootRepository.with_global_proxy
          end

          repos = root_repos.uniq.collect(&:library_instance)

          unless repos.empty?
            ForemanTasks.async_task(
              ::Actions::BulkAction,
              ::Actions::Katello::Repository::UpdateHttpProxyDetails,
              repos.sort_by(&:pulp_id))
          end
        end
      end

      def name_and_url
        uri = URI(url)
        uri.password = nil
        uri.user = nil
        "#{name} (#{uri})"
      end
    end
  end
end
