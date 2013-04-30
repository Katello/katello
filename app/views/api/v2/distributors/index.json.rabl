collection @distributors

attributes :id, :name, :description, :uuid, :location
attributes :environment_id, :serviceLevel
child :environment => :environment do
	extends 'api/v2/environments/show'
end

extends 'api/v2/common/timestamps'
