object @user

attributes :id, :email, :username, :disabled
attributes :default_organization, :default_environment, :own_role_id

extends 'api/v2/common/timestamps'
