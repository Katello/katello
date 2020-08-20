object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends 'katello/api/v2/repositories/base'
  node(:added_to_content_view) { |repo| repo.in_content_view?(@content_view) }
end
