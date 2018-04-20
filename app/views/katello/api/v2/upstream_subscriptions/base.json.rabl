object @resource ||= @object

attributes :pool_id
attributes :status
attributes :quantity
attributes :start_date
attributes :end_date
attributes :contract_number
attributes :consumed
attributes :product_name
attributes :product_id
attributes :subscription_id

if params[:pool_ids]
  attributes :local_pool_ids
end
