object @environment => :environment

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :library

node :prior do |env|
  if env.prior
    {name: env.prior.name, :id => env.prior.id}
  else
    nil
  end

end

node :permissions do |env|
  {
    :view_lifecycle_environments => env.readable?,
    :edit_lifecycle_environments => env.editable?,
    :destroy_lifecycle_environments => env.deletable?,
    :promote_or_remove_content_views_to_environments => env.promotable_or_removable?
  }
end

extends 'katello/api/v2/common/timestamps'
