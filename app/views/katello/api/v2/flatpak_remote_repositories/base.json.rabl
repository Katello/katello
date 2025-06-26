extends 'katello/api/v2/common/identifier'

attributes :name
attributes :label, :flatpak_remote_id

node(:manifest_count) { |repo| repo.manifests.count }
node(:tag_count) { |_repo| 1 }
node(:last_mirrored) { |repo| repo.last_mirrored_status }
