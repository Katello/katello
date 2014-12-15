
object @resource

extends 'katello/api/v2/common/identifier'

attributes :version, :major, :minor
attributes :composite_content_view_ids
attributes :content_view_id
attributes :default
attributes :description
attributes :package_count
attributes :puppet_module_count
attributes :docker_image_count
attributes :docker_tag_count

node :errata_counts do |version|
  partial('katello/api/v2/errata/counts', :object => Katello::RelationPresenter.new(version.errata))
end

child :content_view => :content_view do
  attributes :id, :name, :label
end

child :composite_content_views do
  attributes :id, :name, :label
end

node :permissions do |cvv|
  {
    :deletable => cvv.removable?
  }
end

extends 'katello/api/v2/common/timestamps'

version = @object || @resource
child :environments => :environments do
  attributes :id, :name, :label

  node :permissions do |env|
    {
      :readable => env.readable?,
      :promotable_or_removable => env.promotable_or_removable?,
      :all_systems_editable => Katello::System.all_editable?(version.content_view_id, env.id),
      :all_keys_editable => Katello::System.all_editable?(version.content_view_id, env.id)
    }
  end

  node :system_count do |env|
    Katello::System.in_environment(env).where(:content_view_id => version.content_view_id).count
  end

  node :activation_key_count do |env|
    Katello::ActivationKey.where(:environment_id => env.id).where(:content_view_id => version.content_view_id).count
  end
end

child :archived_repos => :repositories do
  attributes :id, :name, :label
end

child :last_event => :last_event do
  extends 'katello/api/v2/content_view_histories/show'
end

child :active_history => :active_history do
  extends 'katello/api/v2/content_view_histories/show'
end
