object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends "katello/api/v2/repositories/base"
end

if @organization
  node :org_repository_count do
    @organization.repositories.count
  end
end
