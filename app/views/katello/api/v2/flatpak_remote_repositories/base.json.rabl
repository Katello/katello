extends 'katello/api/v2/common/identifier'

attributes :name
attributes :label, :flatpak_remote_id

node(:last_mirrored) { |repo| repo.last_mirrored_status }
