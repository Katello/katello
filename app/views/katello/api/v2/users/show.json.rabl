object @user

attributes :id, :email, :username, :disabled
attributes :default_organization, :default_environment, :own_role_id
attributes :allowed_organizations
attributes :preferences


extends 'api/v2/common/timestamps'
