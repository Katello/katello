object @user

attributes :id, :mail, :login, :disabled
attributes :default_organization

child :allowed_organizations, :root => :allowed_organizations do
  attributes :id, :label, :name
end

attributes :preferences

extends 'katello/api/v2/common/timestamps'
