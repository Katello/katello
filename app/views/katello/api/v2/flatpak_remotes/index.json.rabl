object false

extends "katello/api/v2/common/index"
extends 'katello/api/v2/flatpak_remotes/permissions'

node :has_redhat_flatpak_remote do
  User.as_anonymous_admin do
    query = ::Katello::FlatpakRemote.where("url LIKE ?", "%flatpaks.redhat.io%")
    query = query.where(organization_id: @organization.id) if @organization
    query.exists?
  end
end

child @collection[:results] => :results do
  extends "katello/api/v2/flatpak_remotes/base"
end
