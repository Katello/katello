# TODO: RAILS32 Clean-up
if RUBY_VERSION >= "1.9.3" || Rails::VERSION::STRING >= '3.2.0'
  require 'securerandom'
else
  require 'active_support/secure_random'
end

begin
  # Read token string from the file.
  token = IO.read('/etc/katello/secret_token')
  raise RuntimeError, 'Size is too small' if token.length < 9
  Src::Application.config.secret_token = token.chomp
rescue Exception => e
  # If anything is wrong make sure the token is random. This is safe even when
  # Katello is not configured correctly for any reason (but session is lost
  # after each restart).
  Rails.logger.warn "Using randomly generated secure token: #{e.message}"
  Src::Application.config.secret_token = (RUBY_VERSION >= "1.9.3" || Rails::VERSION::STRING >= '3.2.0') ? SecureRandom.hex(80) : ActiveSupport::SecureRandom.hex(80)
end
