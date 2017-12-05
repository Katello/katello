attribute :enabled, :product_id
node :content do |pc|
  c = pc.content
  {
    id: c.cp_content_id,
    name: c.name,
    label: c.label,
    vendor: c.vendor,
    type: c.content_type,
    gpgUrl: c.gpg_url,
    contentUrl: c.content_url,
    modifiedProductIds: c.modified_product_ids
  }
end
