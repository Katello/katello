collection @distributors

attributes :id, :name, :description, :uuid, :location
attributes :environment_id, :serviceLevel
child :environment => :environment do
  extends 'katello/api/v2/environments/show'
end

extends 'katello/api/v2/common/timestamps'
