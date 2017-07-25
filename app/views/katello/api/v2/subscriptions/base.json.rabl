object @resource ||= @object

attributes :id
attributes :cp_id
attributes :subscription_id
attributes :name
attributes :start_date, :end_date
attributes :available, :quantity, :consumed
attributes :account_number, :contract_number
attributes :support_level
attributes :product_id
attributes :sockets, :cores, :ram
attributes :instance_multiplier, :stacking_id, :multi_entitlement
attributes :type
attributes :name => :product_name
attributes :unmapped_guest
attributes :virt_only
attributes :virt_who
