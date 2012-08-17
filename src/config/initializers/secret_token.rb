require 'active_support/secure_random'

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
  Src::Application.config.secret_token = ActiveSupport::SecureRandom.hex(80)
end
