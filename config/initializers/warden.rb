require 'net/ldap'

Rails.configuration.middleware.use RailsWarden::Manager do |config|
  config.failure_app = FailedAuthenticationController
  config.default_scope = :user

  # all UI requests are handled in the default scope
  config.scope_defaults(
    :user,
    :strategies   => [:sso, AppConfig.warden.to_sym],
    :store        => true,
    :action       => 'unauthenticated_ui'
  )

  # API requests are handled in the :api scope
  config.scope_defaults(
    :api,
    :strategies   => [:sso, :certificate, AppConfig.warden.to_sym],
    :store        => false,
    :action       => 'unauthenticated_api'
  )
end

class Warden::SessionSerializer
  def serialize(user)
    raise ArgumentError, "Cannot serialize invalid user object: #{user}" if not user.is_a? User and user.id.is_a? Integer
    user.id
  end

  def deserialize(id)
    raise ArgumentError, "Cannot deserialize non-integer id: #{id}" unless id.is_a? Integer
    User.find(id) rescue nil
  end
end

# authenticate against database
Warden::Strategies.add(:database) do

  # relevant only when username and password params are set
  def valid?
    params[:username] && params[:password]
  end

  def authenticate!
    Rails.logger.debug("Warden is authenticating #{params[:username]} against database")
    u = User.authenticate!(params[:username], params[:password])
    u ? success!(u) : fail!("Username or password is not correct - could not log in")
  end
end

# authenticate against LDAP
Warden::Strategies.add(:ldap) do  

  # relevant only when username and password params are set
  def valid?
    params[:username] && params[:password]
  end
  
  def authenticate!
    Rails.logger.debug("Warden is authenticating #{params[:username]} against ldap")
    u = User.authenticate_using_ldap!(params[:username], params[:password])
    u ? success!(u) : fail!("Could not log in")
  end
end

Warden::Strategies.add(:certificate) do

  def valid?
    true
  end

  def authenticate!
    return fail('No ssl client certificate, skipping ssl-certificate authentication') if request.env['SSL_CLIENT_CERT'].blank?

    consumer_cert = OpenSSL::X509::Certificate.new(request.env['SSL_CLIENT_CERT'])
    u = CpConsumerUser.new(:uuid => uuid(consumer_cert), :username => uuid(consumer_cert))
    success!(u)
  end

  def uuid(cert)
    drop_cn_prefix_from_subject(cert.subject.to_s)
  end

  def drop_cn_prefix_from_subject(subject_string)
    subject_string.sub(/\/CN=/i, '')
  end
end

Warden::Strategies.add(:sso) do
  def valid?
    true
  end

  def authenticate!
    return fail('No X-Forwarded-User header, skipping sso authentication') if request.env['X-Forwarded-User'].blank?

    user_id = request.env['X-Forwarded-User']
    u = User.User.where(:username => user_id).first
    u ? success!(u) : fail!("Username is not correct - could not log in")
  end
end

