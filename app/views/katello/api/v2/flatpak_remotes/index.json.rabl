object false

extends "katello/api/v2/common/index"
extends 'katello/api/v2/flatpak_remotes/permissions'

child @collection[:results] => :results do
  extends "katello/api/v2/flatpak_remotes/base"
end
