attribute :enabled, :product_id

glue :content do |_content|
  attributes :name, :label, :vendor,
             :cp_content_id => :id,
             :content_type => :contentType,
             :gpg_url => :gpgUrl,
             :content_url => :contentUrl
end
