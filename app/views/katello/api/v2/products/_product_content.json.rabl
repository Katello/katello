attribute :enabled, :product_id

child :content do |_content|
  attributes :name, :label, :vendor, :content_url, :gpg_url
  attributes :cp_content_id => :id
  attributes :content_type => :type
  attributes :gpg_url => :gpgUrl
  attributes :content_url => :contentUrl
end
