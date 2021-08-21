object @resource

extends "katello/api/v2/content_view_versions/base"

node :errata_counts do |version|
  partial('katello/api/v2/errata/counts', :object => Katello::RelationPresenter.new(version.errata))
end

version = @object || @resource
child :environments => :environments do
  attributes :id, :name, :label

  node :publish_date do |env|
    time_ago_in_words(version.env_promote_date(env))
  end

  node :permissions do |env|
    {
      :readable => env.readable?,
      :promotable_or_removable => env.promotable_or_removable?,
      :all_hosts_editable => version.all_hosts_editable?(env),
      :all_keys_editable => Katello::ActivationKey.all_editable?(version.content_view_id, env.id)
    }
  end

  node :host_count do |env|
    ::Host.authorized('view_hosts').in_content_view_environment(:content_view => version.content_view, :lifecycle_environment => env).count
  end

  node :activation_key_count do |env|
    Katello::ActivationKey.where(:environment_id => env.id).where(:content_view_id => version.content_view_id).count
  end
end

child :archived_repos => :repositories do
  attributes :id, :name, :label, :content_type, :library_instance_id
end

child :last_event => :last_event do
  extends 'katello/api/v2/content_view_histories/show'
end

child :active_history => :active_history do
  extends 'katello/api/v2/content_view_histories/show'
end
