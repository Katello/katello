class AddHttpProxyPolicyToRepositoryRoot < ActiveRecord::Migration[5.2]
  def change
    add_column :katello_root_repositories, :http_proxy_policy, :string,
      default: Katello::RootRepository::GLOBAL_DEFAULT_HTTP_PROXY

    Katello::RootRepository.where(ignore_global_proxy: true).each do |repo|
      repo.update(http_proxy_policy: Katello::RootRepository::NO_DEFAULT_HTTP_PROXY)
    end

    remove_column :katello_root_repositories, :ignore_global_proxy
  end
end
