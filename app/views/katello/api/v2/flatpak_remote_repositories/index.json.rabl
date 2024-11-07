object false

extends "katello/api/v2/common/index"

child @collection[:results] => :results do
  extends "katello/api/v2/flatpak_remote_repositories/base"
end
