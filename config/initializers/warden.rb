require 'oauth/request_proxy/rack_request'

Rails.configuration.middleware.use RailsWarden::Manager do |config|
  config.failure_app = FailedAuthenticationController
  config.default_scope = :user

  # all UI requests are handled in the default scope
  config.scope_defaults(
    :user,
    :strategies   => [:sso, Katello.config.warden.to_sym],
    :store        => true,
    :action       => 'unauthenticated_ui'
  )

  # API requests are handled in the :api scope
  config.scope_defaults(
    :api,
    :strategies   => [:oauth, :sso, :certificate, Katello.config.warden.to_sym, :no_credentials],
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

Warden::Manager.after_authentication do |user,auth,opts|
  user = user.username if user.respond_to? :username
  message = auth.winning_strategy.message
  Rails.logger.debug "User #{user} authenticated: #{auth.winning_strategy.message}"
end

# authenticate against database
Warden::Strategies.add(:database) do

  # relevant only when username and password params are set
  def valid?
    (params[:username] && params[:password]) or (params[:auth_username] && params[:auth_password])
  end

  def authenticate!
    if params[:auth_username] && params[:auth_password]
      # API simple auth
      Rails.logger.debug("Warden is authenticating #{params[:auth_username]} against database")
      u = User.authenticate!(params[:auth_username], params[:auth_password])
    elsif params[:username] && params[:password]
      # UI form
      Rails.logger.debug("Warden is authenticating #{params[:username]} against database")
      u = User.authenticate!(params[:username], params[:password])
    end
    u ? success!(u, "database") : fail!("Username or password do not match database - could not log in")
  end
end

# authenticate against LDAP
Warden::Strategies.add(:ldap) do

  # relevant only when username and password params are set
  def valid?
    (params[:username] && params[:password]) or (params[:auth_username] && params[:auth_password])
  end

  def authenticate!
    if params[:auth_username] && params[:auth_password]
      # API simple auth
      Rails.logger.debug("Warden is authenticating #{params[:auth_username]} against ldap")
      u = User.authenticate_using_ldap!(params[:auth_username], params[:auth_password])
    elsif params[:username] && params[:password]
      # UI form
      Rails.logger.debug("Warden is authenticating #{params[:username]} against ldap")
      u = User.authenticate_using_ldap!(params[:username], params[:password])
    end
    u ? success!(u, "LDAP") : fail!("Could not log in using LDAP")
  end
end

Warden::Strategies.add(:certificate) do

  def valid?
    true
  end

  def authenticate!
    ssl_client_cert = client_cert_from_request
    return fail('No ssl client certificate, skipping ssl-certificate authentication') if ssl_client_cert.blank?
    consumer_cert = OpenSSL::X509::Certificate.new(ssl_client_cert)
    uuid = uuid(consumer_cert)
    u = CpConsumerUser.new(:uuid =>uuid, :username =>uuid, :remote_id=> uuid)
    success!(u, "certificate")
  end

  def client_cert_from_request
    cert = request.env['SSL_CLIENT_CERT'] || request.env['HTTP_SSL_CLIENT_CERT']
    return nil if cert.blank? || cert == "(null)"
    # apache does not preserve new lines in cert file - work-around:
    if cert.include?("-----BEGIN CERTIFICATE----- ")
      cert = cert.to_s.gsub("-----BEGIN CERTIFICATE----- ","").gsub(" -----END CERTIFICATE-----","")
      cert.gsub!(" ","\n")
      cert = "-----BEGIN CERTIFICATE-----\n#{cert}-----END CERTIFICATE-----\n"
    end
    return cert
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
    return fail('No X-Forwarded-User header, skipping sso authentication') if request.env['HTTP_X_FORWARDED_USER'].blank?

    user_id = request.env['HTTP_X_FORWARDED_USER'].split("@").first
    u = User.where(:username => user_id).first
    u ? success!(u, "single sign-on") : fail!("Username is not correct - could not log in")
  end
end

Warden::Strategies.add(:oauth) do
  def valid?
    true
  end

  def authenticate!
    return fail("no 'katello-user' header") if request.headers['HTTP_KATELLO_USER'].blank?

    rack_request = Rack::Request.new(request.env)
    consumer_key = OAuth::RequestProxy.proxy(rack_request).oauth_consumer_key
    signature=OAuth::Signature.build(rack_request) do
      [nil, consumer(consumer_key).secret]
    end

    return fail!("Invalid oauth signature") unless signature.verify

    u = User.where(:username => request.headers['HTTP_KATELLO_USER']).first
    u ? success!(u, "OAuth") : fail!("Username is not correct - could not log in")
  rescue OAuth::Signature::UnknownSignatureMethod => e
    Rails.logger.error "Unknown oauth signature method"+ e.to_s
    fail!("Unknown oauth signature method"+ e.to_s)
  rescue => e
    Rails.logger.error "exception occurred while authenticating via oauth "+ e.to_s
    fail!("exception occurred while authenticating via oauth "+ e.to_s)
  end

  def consumer(consumer_key)
    OAuth::Consumer.new Katello.config[consumer_key.to_sym].oauth_key,
                        Katello.config[consumer_key.to_sym].oauth_secret
  end
end

Warden::Strategies.add(:no_credentials) do
  def valid?
    true
  end

  def authenticate!
    custom! [401, {"WWW-Authenticate" => 'Basic realm="Secure Area"'}, ["No Credentials provided"]]
  end
end
