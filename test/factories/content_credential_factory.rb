FactoryBot.define do
  factory :katello_content_credential, :class => Katello::ContentCredential do
    content do
      cert = OpenSSL::X509::Certificate.new
      key = OpenSSL::PKey::RSA.new(2048)
      cert.public_key = key.public_key
      cert.not_before  = Time.now
      cert.not_after   = Time.now + 1000
      cert.sign key, OpenSSL::Digest.new('SHA256')
      cert.to_pem
    end

    sequence(:name) { |n| "content_credential#{n}" }
  end
end
