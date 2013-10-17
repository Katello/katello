object @user

attributes :id, :mail, :login, :disabled
attributes :default_organization, :default_environment, :own_role_id

extends 'api/v2/common/timestamps'
