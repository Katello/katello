object false

extends "katello/api/v2/common/index"
extends 'katello/api/v2/flatpak_remotes/permissions'

node :has_redhat_flatpak_remote do
  User.as_anonymous_admin do
    ::Katello::FlatpakRemote.unscoped.where("url LIKE ?", "%flatpaks.redhat.io%").exists?
  end
end

child @collection[:results] => :results do
  extends "katello/api/v2/flatpak_remotes/base"
end
